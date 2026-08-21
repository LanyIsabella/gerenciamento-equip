from fastapi import FastAPI
from .equipamentos import controller as equipamentos_controller
from .manutencoes import controller as manutencoes_controller

app = FastAPI(title="Gerenciador de Equipamentos", version="1.0.0", description="API para gerenciar equipamentos e suas manutenções.")
app.include_router(equipamentos_controller.router)
app.include_router(manutencoes_controller.router)


'''@app.get("/")

def raiz_projeto():
    return {"message": "Bem-vindo ao Gerenciador de Equipamentos!"}


@app.get("/equipamentos")
def listar_equipamentos():
    return [
        {
            "id_equipamento": 1, "nome": "Computador Dell", "descricao": "Computador de mesa para escritório", "data_aquisicao": "2022-01-15", "status": "Em uso"
        },
        {
            "id_equipamento": 2, "nome": "Impressora HP", "descricao": "Impressora a laser para documentos", "data_aquisicao": "2021-11-10", "status": "Em manutenção"
        },
        {
            "id_equipamento": 3, "nome": "Projetor Epson", "descricao": "Projetor para apresentações", "data_aquisicao": "2020-05-20", "status": "Disponível"
        }
    ]'''