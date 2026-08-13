from fastapi import FastAPI

app = FastAPI(title="Gerenciador de Equipamentos", version="1.0.0", description="API para gerenciar equipamentos e suas manutenções.")

@app.get("/")

def raiz_projeto():
    return {"message": "Bem-vindo ao Gerenciador de Equipamentos!"}