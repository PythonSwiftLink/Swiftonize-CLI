import ast
from pprint import pprint

from ast import ImportFrom

INTS = ["int", "int32", "int64", "int16", "int8", "uint", "uint64", "uint32", "uint16", "uint8" ]
FLOATS = ["float", "float32", "float16", "double"]
STRINGS = ["URL","Error"]
BYTES = ["data"]
BUFFERS = ["CVPixelBuffer"]



class whatever:

    @property
    def x(self) -> str:
        "getter"


whatever().x

def convert_types(input: str) -> str:

    match input:
        case item if item in INTS:
            return "int"
        case item if item in FLOATS:
            return "float"
        case item if item in STRINGS:
            return "str"
        case item if item in BYTES:
            return "bytes"
        case item if item in BUFFERS:
            return "memoryview"
        case _:
            return input


def create_importFrom(module: str, names: list[str]) -> ast.ImportFrom:
    imp = ast.ImportFrom()
    imp.module = "typing"
    imp.level = 0
    typing_names = []
    imp.names = typing_names
    for name in names:
        alias = ast.alias()
        alias.name = name
        alias.asname = None
        typing_names.append(alias)
    return imp

IMPORT_DICT = {
    "typing": ["Optional,Callable"]
} 

class DeleteVisitor(ast.NodeVisitor):

    def visit_Delete(self, node):
        ast.NodeVisitor.generic_visit(self, node)


    def visit_Name(self, node):
        ast.NodeVisitor.generic_visit(self, node)


class ImportVisitor(ast.NodeTransformer):

    def visit_Module(self, node: ast.Module):
        ast.NodeTransformer.generic_visit(self,node)
        body = node.body
        # body extracted to var "body"
        
        for key,value in IMPORT_DICT.items():
            body.insert(0,create_importFrom(key,value))
        
        return node

    def visit_Name(self, node: ast.Name):
        #print("\t",node.__dict__)
        node.id = convert_types(node.id)
        ast.NodeTransformer.generic_visit(self,node)

        return node

    def visit_AnnAssign(self, node: ast.AnnAssign) -> object:
        #print(node.__dict__)
        ast.NodeTransformer.generic_visit(self,node)
        return node

    def visit_Assign(self, node: ast.Assign) -> object:
        ast.NodeTransformer.generic_visit(self,node)
        #print(node.targets[0].id, node.value.func.id)
        target = node.targets[0].id
        t = 'fuck_you'
        _type = "object"
        setter = True
        match node.value:
            case ast.Name() as obj:
                t = obj.id
            case ast.Call() as obj:
                t = obj.func.id
                for arg in obj.args:
                    #print(f"\t{arg}")
                    match arg:
                        case ast.List() as l:
                            for elt in l.elts: ...
                                #print(elt)
                        #case ast.Subscript() as s:
                            
                            #print(f"\t\t{s.__dict__}")
                            #print(s.value.id,s.slice.id)
                        case ast.Name() as n:
                            #print(f"\t\t{n.__dict__}")
                            _type = n.id
                for key in obj.keywords:
                    match key.arg:
                        case "setter":
                            match key.value:
                                case ast.Constant() as c:
                                    setter = c.value
       

        match t:
            case "property":
                setter_string = " / setter" if setter else ""
                return ast.parse(f"@property\ndef {target}(self) -> {_type}: \"getter{setter_string}\"")
        
        return node

    def visit_arg(self, node: ast.arg):
        #print("visit_arg",node.annotation)
        match node.annotation:
            case ast.Subscript() as s:
                #print(s.value)
                match s.value.id:
                    
                    case "callable":
                        s.value.id = "Callable"
        ast.NodeTransformer.generic_visit(self,node)
        

        return node
    #     return super().visit_arg(node)

    def visit_ClassDef(self, node: ast.ClassDef):
        node.decorator_list = []

        for b in node.body: ...
            #print(b)
        ast.NodeTransformer.generic_visit(self,node)
        return node

    def visit_FunctionDef(self, node: ast.FunctionDef):
        node.decorator_list = []
        #print(node.name)
        ast.NodeTransformer.generic_visit(self,node)
        return node

    def visit_ImportFrom(self, node: ImportFrom):

        ast.NodeTransformer.generic_visit(self,node)

        if not node.module in ["swift_types","typing"]:
            #return None
            return node

        #return None
def testParse(src: str) -> str:

    tree = ast.parse(src)
    ImportVisitor().visit(tree)
    output = ast.unparse(ast.fix_missing_locations(tree))
    return str(output)
