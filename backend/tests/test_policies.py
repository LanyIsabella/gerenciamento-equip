from types import SimpleNamespace

import pytest
from app.equipamentos.erros import ResponsavelEquipamentoInvalido
from app.equipamentos.policies import PoliticaCriacaoEquipamento
from app.manutencoes.erros import ResponsavelManutencaoInvalido
from app.manutencoes.policies import PoliticaManutencao
from app.usuarios.enums import CargoUsuario


@pytest.mark.parametrize(
    ("cargo", "permitido"),
    [
        (CargoUsuario.ADMINISTRADOR, True),
        (CargoUsuario.GERENTE, True),
        (CargoUsuario.TECNICO, False),
        (CargoUsuario.VISUALIZADOR, False),
    ],
)
def test_cargos_de_equipamentos(cargo, permitido):
    usuario = SimpleNamespace(cargo=cargo)
    politica = PoliticaCriacaoEquipamento()

    if permitido:
        politica.validar(usuario)
    else:
        with pytest.raises(ResponsavelEquipamentoInvalido):
            politica.validar(usuario)


@pytest.mark.parametrize(
    ("cargo", "permitido"),
    [
        (CargoUsuario.ADMINISTRADOR, True),
        (CargoUsuario.GERENTE, False),
        (CargoUsuario.TECNICO, True),
        (CargoUsuario.VISUALIZADOR, False),
    ],
)
def test_cargos_de_manutencoes(cargo, permitido):
    usuario = SimpleNamespace(cargo=cargo)
    politica = PoliticaManutencao()

    if permitido:
        politica.validar(usuario)
    else:
        with pytest.raises(ResponsavelManutencaoInvalido):
            politica.validar(usuario)
