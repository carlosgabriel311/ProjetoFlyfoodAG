class Individuo
    attr_accessor :cromossomo, :fitness
end

def pegarDadosArquivo(nomeArquivo)
    file = File.open(nomeArquivo + ".txt", "r")
    file.each do |linha|
        pontostemp = [nil, nil, nil]
        num = 0
        encontrou = false
        valor0 = ""
        valor1 = ""
        valor2 = ""
        linha.length.times do |i|
            if linha[i] != " " and linha[i] != "\n"
                if num == 0
                    valor0 += linha[i]
                    encontrou = true
                elsif num == 1
                    valor1 += linha[i]
                else
                    valor2 += linha[i]
                end
            elsif encontrou
                num += 1
            end
        end
        pontostemp[0] = valor0
        pontostemp[1] = valor1.to_f
        pontostemp[2] = valor2.to_f
        $arrayPontos.push(pontostemp)

    end
    file.close()
end

def gerarPopulaçãoInicial(população)
    genes = []
    $tamIndividuo.times do |i|
        genes[i] = i+1
    end
    $tamPopulação.times do |i|
        cromossomo = genes.shuffle
        gerarIndividuo(população, i, cromossomo)
    end
end

def calcularFitness(cromossomo)
    somador = 0
    ($tamIndividuo-1).times do |i|
        somador += ($arrayPontos[cromossomo[i]][1] - $arrayPontos[cromossomo[i+1]][1]).abs() + ($arrayPontos[cromossomo[i]][2] - $arrayPontos[cromossomo[i+1]][2]).abs()
    end
    somador += ($arrayPontos[0][1] - $arrayPontos[cromossomo[0]][1]).abs() + ($arrayPontos[0][2] - $arrayPontos[cromossomo[0]][2]).abs()
    somador += ($arrayPontos[cromossomo[$tamIndividuo-1]][1] - $arrayPontos[0][1]).abs() + ($arrayPontos[cromossomo[$tamIndividuo-1]][2] - $arrayPontos[0][2]).abs()
    return somador
end

def seleçãoPais(população, pais)
    $tamPopulação.times do |i|
        a = rand($tamPopulação)
        b = rand($tamPopulação)
        if população[a].fitness < população[b].fitness
            pais[i] = a
        else
            pais[i] = b
        end
    end
end

def crossover(população, pais, filhos)
    i = 0
    while i < $tamPopulação do
        if rand() <= $probabilidadeCrossover
            corte = rand(1..$tamIndividuo)
            2.times do |j|
                pai1 = população[pais[i]].cromossomo 
                pai2 = população[pais[i+1]].cromossomo
                corte.times do |k|
                    if pai1[k] != pai2[k]
                        if j == 0
                            $tamIndividuo.times do |m|
                                if pai1[k] == pai2[m]
                                    swap(pai2, k, m)
                                    break
                                end
                            end
                        else
                            $tamIndividuo.times do |m|
                                if pai2[k] == pai1[m]
                                    swap(pai1, k, m)
                                    break
                                end
                            end
                        end
                    end
                end
                filho = []
                if j == 0
                    filho.concat(pai1[0..corte-1], pai2[corte..])
                else
                    filho.concat(pai2[0..corte-1], pai1[corte..])
                end
                mutação(filho)
                gerarIndividuo(filhos, i+j, filho)
            end
        else
            2.times do |j|
                gerarIndividuo(filhos, i+j, população[pais[i+j]].cromossomo)
            end
        end 
        i += 2
    end
end

def mutação(filho)
    $tamIndividuo.times do |i|
        if rand <= $probabilidadeMutação
            a = rand($tamIndividuo)
            swap(filho, i, a)
        end
    end
end

def swap(lista, i, j)
    temp = lista[i]
    lista[i] = lista[j]
    lista[j] = temp
end

def gerarIndividuo(lista, i, genes)
    lista[i] = Individuo.new
    lista[i].cromossomo = genes
    lista[i].fitness = calcularFitness(genes)
end

def substituirPopulação(população, filhos, indexMelhor)
    elitismo = true
    if elitismo
        indexPior = procurarPior(filhos)
        filhos[indexPior] = população[indexMelhor]
    end
    return filhos.clone
end

def procurarMelhor(população)
    menor = população[0].fitness
    indexMenor = 0
    $tamPopulação.times do |i|
        if população[i].fitness < menor
            menor = população[i].fitness
            indexMenor = i
        end
    end
    return indexMenor
end
def procurarPior(população)
    maior = população[0].fitness
    indexPior = 0
    $tamPopulação.times do |i|
        if população[i].fitness > maior
            maior = população[i].fitness
            indexPior = i
        end
    end
    return indexPior
end

def escreverArquivo(dado, nome)
    arq = File.open(nome, "a")
    arq.write dado
    arq.write "/"
    arq.close
end

def limparArquivo()
    arq = File.open("resultado.txt", "w")
    arq.write ""
    arq.close
end

srand 70
indexMenor = quantMaxGeração = countConvergencia = 0
$tamPopulação = 200
$probabilidadeCrossover = 0.9
$probabilidadeMutação = 0.01
$arrayPontos = []
população = []
pais = []
filhos = []
print "Informe o nome do arquivo: "
nomeArquivo = gets.chomp()
ini = Time.now
pegarDadosArquivo(nomeArquivo)
$tamIndividuo = $arrayPontos.length() - 1
gerarPopulaçãoInicial(população)
indexMenor = procurarMelhor(população)
menorFitness = população[indexMenor].fitness
limparArquivo()
escreverArquivo(menorFitness, "resultado.txt")

escreverArquivo("[#{$arrayPontos[0][1]},#{$arrayPontos[0][2]}]", 'pontos.txt')
população[indexMenor].cromossomo.each do |j|
    escreverArquivo("[#{$arrayPontos[j][1]},#{$arrayPontos[j][2]}]", "pontos.txt")
end
escreverArquivo("[#{$arrayPontos[0][1]},#{$arrayPontos[0][2]}]", 'pontos.txt')
escreverArquivo("\n", "pontos.txt")

while quantMaxGeração<5000
    quantMaxGeração += 1
    countConvergencia += 1
    seleçãoPais(população, pais)
    crossover(população, pais, filhos)
    população = substituirPopulação(população, filhos, indexMenor)
    indexMenor = procurarMelhor(população)
    escreverArquivo(população[indexMenor].fitness, "resultado.txt")
    
    if quantMaxGeração  == 100
        escreverArquivo("[#{$arrayPontos[0][1]},#{$arrayPontos[0][2]}]", 'pontos.txt')
        população[indexMenor].cromossomo.each do |j|
            escreverArquivo("[#{$arrayPontos[j][1]},#{$arrayPontos[j][2]}]", "pontos.txt")
        end
        escreverArquivo("[#{$arrayPontos[0][1]},#{$arrayPontos[0][2]}]", 'pontos.txt')
        escreverArquivo("\n", "pontos.txt")
    end

    if população[indexMenor].fitness < menorFitness
        countConvergencia = 0
        menorFitness = população[indexMenor].fitness
    elsif countConvergencia == 500
        break
    end
    
end
população[indexMenor].cromossomo.each do |j|
    print $arrayPontos[j][0]
    print "|"
end
escreverArquivo("[#{$arrayPontos[0][1]},#{$arrayPontos[0][2]}]", 'pontos.txt')
população[indexMenor].cromossomo.each do |j|
    escreverArquivo("[#{$arrayPontos[j][1]},#{$arrayPontos[j][2]}]", "pontos.txt")
end
escreverArquivo("[#{$arrayPontos[0][1]},#{$arrayPontos[0][2]}]", 'pontos.txt')
escreverArquivo("\n", "pontos.txt")
fim = Time.now
print fim - ini
escreverArquivo(fim-ini, "tempo.txt")
