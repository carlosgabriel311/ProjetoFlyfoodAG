import matplotlib.pyplot as plt

def pegarDadosArquivo(nome):
    arquivo = open(nome, 'r')
    dados = arquivo.read().split('/')
    arquivo.close
    return dados

dados = pegarDadosArquivo("resultado.txt")
dados.pop()
geração = []
for c in range(len(dados)):
    geração.append(c)

dados = [num for num in reversed(dados)]
geração = [num for num in reversed(geração)]

plt.plot(geração, dados)
plt.axes((0,20,0,10))
plt.show()