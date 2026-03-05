import Foundation

struct VocabularyDatabase: Sendable {
    static let shared = VocabularyDatabase()

    let words: [Word]

    private init() {
        var allWords: [Word] = []

        // NOUNS - High frequency Brazilian Portuguese
        let nouns: [(String, String, String, String, String, Int, DifficultyTier)] = [
            ("casa", "house", "ˈka.zɐ", "Eu comprei uma casa bonita.", "I bought a beautiful house.", 12, .beginner),
            ("tempo", "time", "ˈtẽ.pu", "Não tenho tempo agora.", "I don't have time now.", 8, .beginner),
            ("dia", "day", "ˈdʒi.ɐ", "Hoje é um bom dia.", "Today is a good day.", 15, .beginner),
            ("homem", "man", "ˈo.mẽj̃", "O homem está trabalhando.", "The man is working.", 22, .beginner),
            ("mulher", "woman", "mu.ˈʎɛɾ", "A mulher é muito inteligente.", "The woman is very intelligent.", 25, .beginner),
            ("vida", "life", "ˈvi.dɐ", "A vida é curta.", "Life is short.", 18, .beginner),
            ("ano", "year", "ˈɐ̃.nu", "Este ano vai ser bom.", "This year will be good.", 10, .beginner),
            ("mundo", "world", "ˈmũ.du", "O mundo é grande.", "The world is big.", 30, .beginner),
            ("país", "country", "pa.ˈis", "O Brasil é um país lindo.", "Brazil is a beautiful country.", 35, .beginner),
            ("mão", "hand", "ˈmɐ̃w̃", "Dê-me sua mão.", "Give me your hand.", 40, .beginner),
            ("filho", "son", "ˈfi.ʎu", "Meu filho tem cinco anos.", "My son is five years old.", 42, .beginner),
            ("olho", "eye", "ˈo.ʎu", "Ela tem olhos verdes.", "She has green eyes.", 55, .beginner),
            ("parte", "part", "ˈpaɾ.tʃi", "Essa é a melhor parte.", "This is the best part.", 20, .beginner),
            ("coisa", "thing", "ˈkoj.zɐ", "Essa coisa é estranha.", "This thing is strange.", 14, .beginner),
            ("cidade", "city", "si.ˈda.dʒi", "A cidade é muito grande.", "The city is very big.", 45, .beginner),
            ("água", "water", "ˈa.ɡwɐ", "Eu preciso de água.", "I need water.", 50, .beginner),
            ("nome", "name", "ˈno.mi", "Qual é o seu nome?", "What is your name?", 28, .beginner),
            ("trabalho", "work/job", "tɾa.ˈba.ʎu", "Eu gosto do meu trabalho.", "I like my job.", 32, .beginner),
            ("criança", "child", "kɾi.ˈɐ̃.sɐ", "A criança está brincando.", "The child is playing.", 60, .beginner),
            ("noite", "night", "ˈnoj.tʃi", "A noite está linda.", "The night is beautiful.", 38, .beginner),
            ("família", "family", "fa.ˈmi.li.ɐ", "Minha família é grande.", "My family is big.", 48, .beginner),
            ("problema", "problem", "pɾo.ˈblɛ.mɐ", "Isso não é um problema.", "That is not a problem.", 52, .beginner),
            ("momento", "moment", "mo.ˈmẽ.tu", "Espere um momento.", "Wait a moment.", 44, .beginner),
            ("amigo", "friend", "a.ˈmi.ɡu", "Ele é meu melhor amigo.", "He is my best friend.", 58, .beginner),
            ("dinheiro", "money", "dʒi.ˈɲej.ɾu", "Eu não tenho dinheiro.", "I don't have money.", 65, .beginner),
            ("porta", "door", "ˈpɔɾ.tɐ", "Feche a porta, por favor.", "Close the door, please.", 70, .elementary),
            ("livro", "book", "ˈli.vɾu", "Esse livro é interessante.", "This book is interesting.", 75, .elementary),
            ("escola", "school", "is.ˈkɔ.lɐ", "As crianças vão à escola.", "The children go to school.", 80, .elementary),
            ("comida", "food", "ko.ˈmi.dɐ", "A comida está deliciosa.", "The food is delicious.", 85, .elementary),
            ("carro", "car", "ˈka.ʁu", "O carro é novo.", "The car is new.", 90, .elementary),
            ("rua", "street", "ˈʁu.ɐ", "A rua está vazia.", "The street is empty.", 92, .elementary),
            ("corpo", "body", "ˈkoɾ.pu", "O corpo precisa de descanso.", "The body needs rest.", 95, .elementary),
            ("mesa", "table", "ˈme.zɐ", "A mesa está posta.", "The table is set.", 100, .elementary),
            ("pessoa", "person", "pe.ˈso.ɐ", "Essa pessoa é gentil.", "This person is kind.", 16, .beginner),
            ("história", "story/history", "is.ˈtɔ.ɾi.ɐ", "Conte-me uma história.", "Tell me a story.", 105, .elementary),
            ("cabeça", "head", "ka.ˈbe.sɐ", "Minha cabeça dói.", "My head hurts.", 108, .elementary),
            ("lugar", "place", "lu.ˈɡaɾ", "Este é um bom lugar.", "This is a good place.", 36, .beginner),
            ("pé", "foot", "ˈpɛ", "Meu pé está doendo.", "My foot hurts.", 110, .elementary),
            ("coração", "heart", "ko.ɾa.ˈsɐ̃w̃", "Meu coração está feliz.", "My heart is happy.", 115, .elementary),
            ("terra", "earth/land", "ˈtɛ.ʁɐ", "A terra é fértil.", "The land is fertile.", 120, .elementary),
            ("palavra", "word", "pa.ˈla.vɾɐ", "Essa palavra é difícil.", "This word is difficult.", 125, .elementary),
            ("mãe", "mother", "ˈmɐ̃j̃", "Minha mãe cozinha bem.", "My mother cooks well.", 46, .beginner),
            ("pai", "father", "ˈpaj", "Meu pai trabalha muito.", "My father works a lot.", 47, .beginner),
            ("irmão", "brother", "iɾ.ˈmɐ̃w̃", "Meu irmão é mais velho.", "My brother is older.", 130, .elementary),
            ("irmã", "sister", "iɾ.ˈmɐ̃", "Minha irmã mora longe.", "My sister lives far away.", 132, .elementary),
            ("avô", "grandfather", "a.ˈvo", "Meu avô conta histórias.", "My grandfather tells stories.", 135, .elementary),
            ("avó", "grandmother", "a.ˈvɔ", "Minha avó faz bolo.", "My grandmother makes cake.", 136, .elementary),
            ("hotel", "hotel", "o.ˈtɛw", "O hotel fica perto da praia.", "The hotel is near the beach.", 140, .elementary),
            ("aeroporto", "airport", "a.e.ɾo.ˈpoɾ.tu", "Vamos ao aeroporto.", "Let's go to the airport.", 145, .elementary),
            ("praia", "beach", "ˈpɾaj.ɐ", "A praia é linda.", "The beach is beautiful.", 148, .elementary),
            ("restaurante", "restaurant", "ʁes.taw.ˈɾɐ̃.tʃi", "O restaurante é caro.", "The restaurant is expensive.", 150, .elementary),
            ("médico", "doctor", "ˈmɛ.dʒi.ku", "Preciso ir ao médico.", "I need to go to the doctor.", 155, .elementary),
            ("reunião", "meeting", "ʁe.u.ni.ˈɐ̃w̃", "A reunião é às três.", "The meeting is at three.", 160, .intermediate),
            ("empresa", "company", "ẽ.ˈpɾe.zɐ", "A empresa está crescendo.", "The company is growing.", 165, .intermediate),
            ("mercado", "market", "meɾ.ˈka.du", "Vou ao mercado comprar frutas.", "I'm going to the market to buy fruits.", 170, .elementary),
            ("igreja", "church", "i.ˈɡɾe.ʒɐ", "A igreja é muito antiga.", "The church is very old.", 175, .elementary),
            ("cozinha", "kitchen", "ko.ˈzi.ɲɐ", "A cozinha está limpa.", "The kitchen is clean.", 180, .elementary),
            ("quarto", "room/bedroom", "ˈkwaɾ.tu", "O quarto é confortável.", "The room is comfortable.", 185, .elementary),
            ("jardim", "garden", "ʒaɾ.ˈdʒĩ", "O jardim tem muitas flores.", "The garden has many flowers.", 190, .elementary),
            ("viagem", "trip/travel", "vi.ˈa.ʒẽj̃", "A viagem foi maravilhosa.", "The trip was wonderful.", 195, .elementary),
            ("telefone", "phone", "te.le.ˈfɔ.ni", "Meu telefone está tocando.", "My phone is ringing.", 200, .elementary),
            ("computador", "computer", "kõ.pu.ta.ˈdoɾ", "O computador é rápido.", "The computer is fast.", 205, .elementary),
            ("projeto", "project", "pɾo.ˈʒɛ.tu", "O projeto está quase pronto.", "The project is almost ready.", 210, .intermediate),
            ("ideia", "idea", "i.ˈdej.ɐ", "Tenho uma boa ideia.", "I have a good idea.", 215, .elementary),
            ("caminho", "path/way", "ka.ˈmi.ɲu", "O caminho é longo.", "The path is long.", 220, .elementary),
            ("lei", "law", "ˈlej", "A lei deve ser respeitada.", "The law must be respected.", 225, .intermediate),
            ("saúde", "health", "sa.ˈu.dʒi", "Saúde é o mais importante.", "Health is the most important.", 230, .elementary),
            ("exemplo", "example", "e.ˈzẽ.plu", "Dê um exemplo.", "Give an example.", 235, .intermediate),
            ("rio", "river", "ˈʁi.u", "O rio é muito largo.", "The river is very wide.", 240, .elementary),
            ("sonho", "dream", "ˈso.ɲu", "Meu sonho é viajar.", "My dream is to travel.", 245, .elementary),
            ("jogo", "game", "ˈʒo.ɡu", "O jogo foi emocionante.", "The game was exciting.", 250, .elementary),
            ("presente", "gift/present", "pɾe.ˈzẽ.tʃi", "Obrigado pelo presente.", "Thank you for the gift.", 255, .elementary),
        ]

        let nounArticles: [String: String] = [
            "casa": "uma", "tempo": "um", "dia": "um", "homem": "um", "mulher": "uma",
            "vida": "uma", "ano": "um", "mundo": "um", "país": "um", "mão": "uma",
            "filho": "um", "olho": "um", "parte": "uma", "coisa": "uma", "cidade": "uma",
            "água": "uma", "nome": "um", "trabalho": "um", "criança": "uma", "noite": "uma",
            "família": "uma", "problema": "um", "momento": "um", "amigo": "um", "dinheiro": "um",
            "porta": "uma", "livro": "um", "escola": "uma", "comida": "uma", "carro": "um",
            "rua": "uma", "corpo": "um", "mesa": "uma", "pessoa": "uma", "história": "uma",
            "cabeça": "uma", "lugar": "um", "pé": "um", "coração": "um", "terra": "uma",
            "palavra": "uma", "mãe": "uma", "pai": "um", "irmão": "um", "irmã": "uma",
            "avô": "um", "avó": "uma", "hotel": "um", "aeroporto": "um", "praia": "uma",
            "restaurante": "um", "médico": "um", "reunião": "uma", "empresa": "uma",
            "mercado": "um", "igreja": "uma", "cozinha": "uma", "quarto": "um", "jardim": "um",
            "viagem": "uma", "telefone": "um", "computador": "um", "projeto": "um",
            "ideia": "uma", "caminho": "um", "lei": "uma", "saúde": "uma", "exemplo": "um",
            "rio": "um", "sonho": "um", "jogo": "um", "presente": "um"
        ]

        for (i, n) in nouns.enumerated() {
            allWords.append(Word(
                id: "noun_\(i)",
                portuguese: n.0,
                english: n.1,
                ipa: n.2,
                partOfSpeech: .noun,
                exampleSentence: n.3,
                exampleTranslation: n.4,
                frequencyRank: n.5,
                difficultyTier: n.6,
                conjugations: nil,
                article: nounArticles[n.0]
            ))
        }

        // VERBS - High frequency Brazilian Portuguese with conjugations
        let verbs: [(String, String, String, String, String, Int, DifficultyTier, VerbConjugations)] = [
            ("ser", "to be (permanent)", "ˈseɾ", "Eu sou brasileiro.", "I am Brazilian.", 1, .beginner,
             VerbConjugations(infinitive: "ser", presentEu: "sou", presentVoce: "é", presentEle: "é", presentNos: "somos", presentVoces: "são", preteriteEu: "fui", preteriteVoce: "foi", preteriteEle: "foi", preteriteNos: "fomos", preteriteVoces: "foram", futureEu: "serei", futureVoce: "será", futureEle: "será", futureNos: "seremos", futureVoces: "serão")),
            ("ter", "to have", "ˈteɾ", "Eu tenho dois filhos.", "I have two children.", 2, .beginner,
             VerbConjugations(infinitive: "ter", presentEu: "tenho", presentVoce: "tem", presentEle: "tem", presentNos: "temos", presentVoces: "têm", preteriteEu: "tive", preteriteVoce: "teve", preteriteEle: "teve", preteriteNos: "tivemos", preteriteVoces: "tiveram", futureEu: "terei", futureVoce: "terá", futureEle: "terá", futureNos: "teremos", futureVoces: "terão")),
            ("estar", "to be (temporary)", "is.ˈtaɾ", "Eu estou cansado.", "I am tired.", 3, .beginner,
             VerbConjugations(infinitive: "estar", presentEu: "estou", presentVoce: "está", presentEle: "está", presentNos: "estamos", presentVoces: "estão", preteriteEu: "estive", preteriteVoce: "esteve", preteriteEle: "esteve", preteriteNos: "estivemos", preteriteVoces: "estiveram", futureEu: "estarei", futureVoce: "estará", futureEle: "estará", futureNos: "estaremos", futureVoces: "estarão")),
            ("fazer", "to do/make", "fa.ˈzeɾ", "O que você vai fazer?", "What are you going to do?", 4, .beginner,
             VerbConjugations(infinitive: "fazer", presentEu: "faço", presentVoce: "faz", presentEle: "faz", presentNos: "fazemos", presentVoces: "fazem", preteriteEu: "fiz", preteriteVoce: "fez", preteriteEle: "fez", preteriteNos: "fizemos", preteriteVoces: "fizeram", futureEu: "farei", futureVoce: "fará", futureEle: "fará", futureNos: "faremos", futureVoces: "farão")),
            ("ir", "to go", "ˈiɾ", "Eu vou ao mercado.", "I'm going to the market.", 5, .beginner,
             VerbConjugations(infinitive: "ir", presentEu: "vou", presentVoce: "vai", presentEle: "vai", presentNos: "vamos", presentVoces: "vão", preteriteEu: "fui", preteriteVoce: "foi", preteriteEle: "foi", preteriteNos: "fomos", preteriteVoces: "foram", futureEu: "irei", futureVoce: "irá", futureEle: "irá", futureNos: "iremos", futureVoces: "irão")),
            ("poder", "to be able to/can", "po.ˈdeɾ", "Eu posso ajudar você.", "I can help you.", 6, .beginner,
             VerbConjugations(infinitive: "poder", presentEu: "posso", presentVoce: "pode", presentEle: "pode", presentNos: "podemos", presentVoces: "podem", preteriteEu: "pude", preteriteVoce: "pôde", preteriteEle: "pôde", preteriteNos: "pudemos", preteriteVoces: "puderam", futureEu: "poderei", futureVoce: "poderá", futureEle: "poderá", futureNos: "poderemos", futureVoces: "poderão")),
            ("dizer", "to say/tell", "dʒi.ˈzeɾ", "O que você quer dizer?", "What do you mean?", 7, .beginner,
             VerbConjugations(infinitive: "dizer", presentEu: "digo", presentVoce: "diz", presentEle: "diz", presentNos: "dizemos", presentVoces: "dizem", preteriteEu: "disse", preteriteVoce: "disse", preteriteEle: "disse", preteriteNos: "dissemos", preteriteVoces: "disseram", futureEu: "direi", futureVoce: "dirá", futureEle: "dirá", futureNos: "diremos", futureVoces: "dirão")),
            ("dar", "to give", "ˈdaɾ", "Vou dar um presente.", "I'm going to give a gift.", 9, .beginner,
             VerbConjugations(infinitive: "dar", presentEu: "dou", presentVoce: "dá", presentEle: "dá", presentNos: "damos", presentVoces: "dão", preteriteEu: "dei", preteriteVoce: "deu", preteriteEle: "deu", preteriteNos: "demos", preteriteVoces: "deram", futureEu: "darei", futureVoce: "dará", futureEle: "dará", futureNos: "daremos", futureVoces: "darão")),
            ("saber", "to know (fact)", "sa.ˈbeɾ", "Eu sei a resposta.", "I know the answer.", 11, .beginner,
             VerbConjugations(infinitive: "saber", presentEu: "sei", presentVoce: "sabe", presentEle: "sabe", presentNos: "sabemos", presentVoces: "sabem", preteriteEu: "soube", preteriteVoce: "soube", preteriteEle: "soube", preteriteNos: "soubemos", preteriteVoces: "souberam", futureEu: "saberei", futureVoce: "saberá", futureEle: "saberá", futureNos: "saberemos", futureVoces: "saberão")),
            ("querer", "to want", "ke.ˈɾeɾ", "Eu quero café.", "I want coffee.", 13, .beginner,
             VerbConjugations(infinitive: "querer", presentEu: "quero", presentVoce: "quer", presentEle: "quer", presentNos: "queremos", presentVoces: "querem", preteriteEu: "quis", preteriteVoce: "quis", preteriteEle: "quis", preteriteNos: "quisemos", preteriteVoces: "quiseram", futureEu: "quererei", futureVoce: "quererá", futureEle: "quererá", futureNos: "quereremos", futureVoces: "quererão")),
            ("falar", "to speak/talk", "fa.ˈlaɾ", "Eu falo português.", "I speak Portuguese.", 17, .beginner,
             VerbConjugations(infinitive: "falar", presentEu: "falo", presentVoce: "fala", presentEle: "fala", presentNos: "falamos", presentVoces: "falam", preteriteEu: "falei", preteriteVoce: "falou", preteriteEle: "falou", preteriteNos: "falamos", preteriteVoces: "falaram", futureEu: "falarei", futureVoce: "falará", futureEle: "falará", futureNos: "falaremos", futureVoces: "falarão")),
            ("ver", "to see", "ˈveɾ", "Eu quero ver o filme.", "I want to see the movie.", 19, .beginner,
             VerbConjugations(infinitive: "ver", presentEu: "vejo", presentVoce: "vê", presentEle: "vê", presentNos: "vemos", presentVoces: "veem", preteriteEu: "vi", preteriteVoce: "viu", preteriteEle: "viu", preteriteNos: "vimos", preteriteVoces: "viram", futureEu: "verei", futureVoce: "verá", futureEle: "verá", futureNos: "veremos", futureVoces: "verão")),
            ("comer", "to eat", "ko.ˈmeɾ", "Vamos comer juntos.", "Let's eat together.", 21, .beginner,
             VerbConjugations(infinitive: "comer", presentEu: "como", presentVoce: "come", presentEle: "come", presentNos: "comemos", presentVoces: "comem", preteriteEu: "comi", preteriteVoce: "comeu", preteriteEle: "comeu", preteriteNos: "comemos", preteriteVoces: "comeram", futureEu: "comerei", futureVoce: "comerá", futureEle: "comerá", futureNos: "comeremos", futureVoces: "comerão")),
            ("beber", "to drink", "be.ˈbeɾ", "Eu bebo água todos os dias.", "I drink water every day.", 23, .beginner,
             VerbConjugations(infinitive: "beber", presentEu: "bebo", presentVoce: "bebe", presentEle: "bebe", presentNos: "bebemos", presentVoces: "bebem", preteriteEu: "bebi", preteriteVoce: "bebeu", preteriteEle: "bebeu", preteriteNos: "bebemos", preteriteVoces: "beberam", futureEu: "beberei", futureVoce: "beberá", futureEle: "beberá", futureNos: "beberemos", futureVoces: "beberão")),
            ("trabalhar", "to work", "tɾa.ba.ˈʎaɾ", "Eu trabalho em casa.", "I work from home.", 26, .beginner,
             VerbConjugations(infinitive: "trabalhar", presentEu: "trabalho", presentVoce: "trabalha", presentEle: "trabalha", presentNos: "trabalhamos", presentVoces: "trabalham", preteriteEu: "trabalhei", preteriteVoce: "trabalhou", preteriteEle: "trabalhou", preteriteNos: "trabalhamos", preteriteVoces: "trabalharam", futureEu: "trabalharei", futureVoce: "trabalhará", futureEle: "trabalhará", futureNos: "trabalharemos", futureVoces: "trabalharão")),
            ("viver", "to live", "vi.ˈveɾ", "Eu vivo no Brasil.", "I live in Brazil.", 27, .beginner,
             VerbConjugations(infinitive: "viver", presentEu: "vivo", presentVoce: "vive", presentEle: "vive", presentNos: "vivemos", presentVoces: "vivem", preteriteEu: "vivi", preteriteVoce: "viveu", preteriteEle: "viveu", preteriteNos: "vivemos", preteriteVoces: "viveram", futureEu: "viverei", futureVoce: "viverá", futureEle: "viverá", futureNos: "viveremos", futureVoces: "viverão")),
            ("gostar", "to like", "ɡos.ˈtaɾ", "Eu gosto de música.", "I like music.", 29, .beginner,
             VerbConjugations(infinitive: "gostar", presentEu: "gosto", presentVoce: "gosta", presentEle: "gosta", presentNos: "gostamos", presentVoces: "gostam", preteriteEu: "gostei", preteriteVoce: "gostou", preteriteEle: "gostou", preteriteNos: "gostamos", preteriteVoces: "gostaram", futureEu: "gostarei", futureVoce: "gostará", futureEle: "gostará", futureNos: "gostaremos", futureVoces: "gostarão")),
            ("comprar", "to buy", "kõ.ˈpɾaɾ", "Preciso comprar pão.", "I need to buy bread.", 31, .beginner,
             VerbConjugations(infinitive: "comprar", presentEu: "compro", presentVoce: "compra", presentEle: "compra", presentNos: "compramos", presentVoces: "compram", preteriteEu: "comprei", preteriteVoce: "comprou", preteriteEle: "comprou", preteriteNos: "compramos", preteriteVoces: "compraram", futureEu: "comprarei", futureVoce: "comprará", futureEle: "comprará", futureNos: "compraremos", futureVoces: "comprarão")),
            ("pensar", "to think", "pẽ.ˈsaɾ", "Eu penso em você.", "I think about you.", 33, .beginner,
             VerbConjugations(infinitive: "pensar", presentEu: "penso", presentVoce: "pensa", presentEle: "pensa", presentNos: "pensamos", presentVoces: "pensam", preteriteEu: "pensei", preteriteVoce: "pensou", preteriteEle: "pensou", preteriteNos: "pensamos", preteriteVoces: "pensaram", futureEu: "pensarei", futureVoce: "pensará", futureEle: "pensará", futureNos: "pensaremos", futureVoces: "pensarão")),
            ("dormir", "to sleep", "doɾ.ˈmiɾ", "Eu durmo cedo.", "I sleep early.", 34, .beginner,
             VerbConjugations(infinitive: "dormir", presentEu: "durmo", presentVoce: "dorme", presentEle: "dorme", presentNos: "dormimos", presentVoces: "dormem", preteriteEu: "dormi", preteriteVoce: "dormiu", preteriteEle: "dormiu", preteriteNos: "dormimos", preteriteVoces: "dormiram", futureEu: "dormirei", futureVoce: "dormirá", futureEle: "dormirá", futureNos: "dormiremos", futureVoces: "dormirão")),
            ("escrever", "to write", "is.kɾe.ˈveɾ", "Eu escrevo todos os dias.", "I write every day.", 37, .beginner,
             VerbConjugations(infinitive: "escrever", presentEu: "escrevo", presentVoce: "escreve", presentEle: "escreve", presentNos: "escrevemos", presentVoces: "escrevem", preteriteEu: "escrevi", preteriteVoce: "escreveu", preteriteEle: "escreveu", preteriteNos: "escrevemos", preteriteVoces: "escreveram", futureEu: "escreverei", futureVoce: "escreverá", futureEle: "escreverá", futureNos: "escreveremos", futureVoces: "escreverão")),
            ("ler", "to read", "ˈleɾ", "Eu leio muitos livros.", "I read many books.", 39, .beginner,
             VerbConjugations(infinitive: "ler", presentEu: "leio", presentVoce: "lê", presentEle: "lê", presentNos: "lemos", presentVoces: "leem", preteriteEu: "li", preteriteVoce: "leu", preteriteEle: "leu", preteriteNos: "lemos", preteriteVoces: "leram", futureEu: "lerei", futureVoce: "lerá", futureEle: "lerá", futureNos: "leremos", futureVoces: "lerão")),
            ("ouvir", "to hear/listen", "o.ˈviɾ", "Eu ouço música no carro.", "I listen to music in the car.", 41, .beginner,
             VerbConjugations(infinitive: "ouvir", presentEu: "ouço", presentVoce: "ouve", presentEle: "ouve", presentNos: "ouvimos", presentVoces: "ouvem", preteriteEu: "ouvi", preteriteVoce: "ouviu", preteriteEle: "ouviu", preteriteNos: "ouvimos", preteriteVoces: "ouviram", futureEu: "ouvirei", futureVoce: "ouvirá", futureEle: "ouvirá", futureNos: "ouviremos", futureVoces: "ouvirão")),
            ("abrir", "to open", "a.ˈbɾiɾ", "Abra a janela, por favor.", "Open the window, please.", 43, .beginner,
             VerbConjugations(infinitive: "abrir", presentEu: "abro", presentVoce: "abre", presentEle: "abre", presentNos: "abrimos", presentVoces: "abrem", preteriteEu: "abri", preteriteVoce: "abriu", preteriteEle: "abriu", preteriteNos: "abrimos", preteriteVoces: "abriram", futureEu: "abrirei", futureVoce: "abrirá", futureEle: "abrirá", futureNos: "abriremos", futureVoces: "abrirão")),
            ("pagar", "to pay", "pa.ˈɡaɾ", "Eu vou pagar a conta.", "I'm going to pay the bill.", 49, .beginner,
             VerbConjugations(infinitive: "pagar", presentEu: "pago", presentVoce: "paga", presentEle: "paga", presentNos: "pagamos", presentVoces: "pagam", preteriteEu: "paguei", preteriteVoce: "pagou", preteriteEle: "pagou", preteriteNos: "pagamos", preteriteVoces: "pagaram", futureEu: "pagarei", futureVoce: "pagará", futureEle: "pagará", futureNos: "pagaremos", futureVoces: "pagarão")),
            ("ajudar", "to help", "a.ʒu.ˈdaɾ", "Posso ajudar você?", "Can I help you?", 51, .beginner,
             VerbConjugations(infinitive: "ajudar", presentEu: "ajudo", presentVoce: "ajuda", presentEle: "ajuda", presentNos: "ajudamos", presentVoces: "ajudam", preteriteEu: "ajudei", preteriteVoce: "ajudou", preteriteEle: "ajudou", preteriteNos: "ajudamos", preteriteVoces: "ajudaram", futureEu: "ajudarei", futureVoce: "ajudará", futureEle: "ajudará", futureNos: "ajudaremos", futureVoces: "ajudarão")),
            ("aprender", "to learn", "a.pɾẽ.ˈdeɾ", "Eu aprendo rápido.", "I learn fast.", 53, .beginner,
             VerbConjugations(infinitive: "aprender", presentEu: "aprendo", presentVoce: "aprende", presentEle: "aprende", presentNos: "aprendemos", presentVoces: "aprendem", preteriteEu: "aprendi", preteriteVoce: "aprendeu", preteriteEle: "aprendeu", preteriteNos: "aprendemos", preteriteVoces: "aprenderam", futureEu: "aprenderei", futureVoce: "aprenderá", futureEle: "aprenderá", futureNos: "aprenderemos", futureVoces: "aprenderão")),
            ("correr", "to run", "ko.ˈʁeɾ", "Eu corro de manhã.", "I run in the morning.", 56, .elementary,
             VerbConjugations(infinitive: "correr", presentEu: "corro", presentVoce: "corre", presentEle: "corre", presentNos: "corremos", presentVoces: "correm", preteriteEu: "corri", preteriteVoce: "correu", preteriteEle: "correu", preteriteNos: "corremos", preteriteVoces: "correram", futureEu: "correrei", futureVoce: "correrá", futureEle: "correrá", futureNos: "correremos", futureVoces: "correrão")),
            ("vender", "to sell", "vẽ.ˈdeɾ", "Ele vende carros.", "He sells cars.", 57, .elementary,
             VerbConjugations(infinitive: "vender", presentEu: "vendo", presentVoce: "vende", presentEle: "vende", presentNos: "vendemos", presentVoces: "vendem", preteriteEu: "vendi", preteriteVoce: "vendeu", preteriteEle: "vendeu", preteriteNos: "vendemos", preteriteVoces: "venderam", futureEu: "venderei", futureVoce: "venderá", futureEle: "venderá", futureNos: "venderemos", futureVoces: "venderão")),
            ("esperar", "to wait/hope", "is.pe.ˈɾaɾ", "Espere um momento.", "Wait a moment.", 59, .elementary,
             VerbConjugations(infinitive: "esperar", presentEu: "espero", presentVoce: "espera", presentEle: "espera", presentNos: "esperamos", presentVoces: "esperam", preteriteEu: "esperei", preteriteVoce: "esperou", preteriteEle: "esperou", preteriteNos: "esperamos", preteriteVoces: "esperaram", futureEu: "esperarei", futureVoce: "esperará", futureEle: "esperará", futureNos: "esperaremos", futureVoces: "esperarão")),
            ("viajar", "to travel", "vi.a.ˈʒaɾ", "Eu adoro viajar.", "I love to travel.", 62, .elementary,
             VerbConjugations(infinitive: "viajar", presentEu: "viajo", presentVoce: "viaja", presentEle: "viaja", presentNos: "viajamos", presentVoces: "viajam", preteriteEu: "viajei", preteriteVoce: "viajou", preteriteEle: "viajou", preteriteNos: "viajamos", preteriteVoces: "viajaram", futureEu: "viajarei", futureVoce: "viajará", futureEle: "viajará", futureNos: "viajaremos", futureVoces: "viajarão")),
            ("cozinhar", "to cook", "ko.zi.ˈɲaɾ", "Eu cozinho todos os dias.", "I cook every day.", 64, .elementary,
             VerbConjugations(infinitive: "cozinhar", presentEu: "cozinho", presentVoce: "cozinha", presentEle: "cozinha", presentNos: "cozinhamos", presentVoces: "cozinham", preteriteEu: "cozinhei", preteriteVoce: "cozinhou", preteriteEle: "cozinhou", preteriteNos: "cozinhamos", preteriteVoces: "cozinharam", futureEu: "cozinharei", futureVoce: "cozinhará", futureEle: "cozinhará", futureNos: "cozinharemos", futureVoces: "cozinharão")),
            ("estudar", "to study", "is.tu.ˈdaɾ", "Eu estudo português.", "I study Portuguese.", 66, .elementary,
             VerbConjugations(infinitive: "estudar", presentEu: "estudo", presentVoce: "estuda", presentEle: "estuda", presentNos: "estudamos", presentVoces: "estudam", preteriteEu: "estudei", preteriteVoce: "estudou", preteriteEle: "estudou", preteriteNos: "estudamos", preteriteVoces: "estudaram", futureEu: "estudarei", futureVoce: "estudará", futureEle: "estudará", futureNos: "estudaremos", futureVoces: "estudarão")),
            ("morar", "to live (reside)", "mo.ˈɾaɾ", "Eu moro em São Paulo.", "I live in São Paulo.", 68, .elementary,
             VerbConjugations(infinitive: "morar", presentEu: "moro", presentVoce: "mora", presentEle: "mora", presentNos: "moramos", presentVoces: "moram", preteriteEu: "morei", preteriteVoce: "morou", preteriteEle: "morou", preteriteNos: "moramos", preteriteVoces: "moraram", futureEu: "morarei", futureVoce: "morará", futureEle: "morará", futureNos: "moraremos", futureVoces: "morarão")),
            ("precisar", "to need", "pɾe.si.ˈzaɾ", "Eu preciso de ajuda.", "I need help.", 24, .beginner,
             VerbConjugations(infinitive: "precisar", presentEu: "preciso", presentVoce: "precisa", presentEle: "precisa", presentNos: "precisamos", presentVoces: "precisam", preteriteEu: "precisei", preteriteVoce: "precisou", preteriteEle: "precisou", preteriteNos: "precisamos", preteriteVoces: "precisaram", futureEu: "precisarei", futureVoce: "precisará", futureEle: "precisará", futureNos: "precisaremos", futureVoces: "precisarão")),
            ("ficar", "to stay/become", "fi.ˈkaɾ", "Eu fico em casa hoje.", "I'm staying home today.", 54, .beginner,
             VerbConjugations(infinitive: "ficar", presentEu: "fico", presentVoce: "fica", presentEle: "fica", presentNos: "ficamos", presentVoces: "ficam", preteriteEu: "fiquei", preteriteVoce: "ficou", preteriteEle: "ficou", preteriteNos: "ficamos", preteriteVoces: "ficaram", futureEu: "ficarei", futureVoce: "ficará", futureEle: "ficará", futureNos: "ficaremos", futureVoces: "ficarão")),
            ("encontrar", "to find/meet", "ẽ.kõ.ˈtɾaɾ", "Eu encontrei meu amigo.", "I met my friend.", 61, .elementary,
             VerbConjugations(infinitive: "encontrar", presentEu: "encontro", presentVoce: "encontra", presentEle: "encontra", presentNos: "encontramos", presentVoces: "encontram", preteriteEu: "encontrei", preteriteVoce: "encontrou", preteriteEle: "encontrou", preteriteNos: "encontramos", preteriteVoces: "encontraram", futureEu: "encontrarei", futureVoce: "encontrará", futureEle: "encontrará", futureNos: "encontraremos", futureVoces: "encontrarão")),
            ("decidir", "to decide", "de.si.ˈdʒiɾ", "Eu preciso decidir logo.", "I need to decide soon.", 72, .intermediate,
             VerbConjugations(infinitive: "decidir", presentEu: "decido", presentVoce: "decide", presentEle: "decide", presentNos: "decidimos", presentVoces: "decidem", preteriteEu: "decidi", preteriteVoce: "decidiu", preteriteEle: "decidiu", preteriteNos: "decidimos", preteriteVoces: "decidiram", futureEu: "decidirei", futureVoce: "decidirá", futureEle: "decidirá", futureNos: "decidiremos", futureVoces: "decidirão")),
        ]

        for (i, v) in verbs.enumerated() {
            allWords.append(Word(
                id: "verb_\(i)",
                portuguese: v.0,
                english: v.1,
                ipa: v.2,
                partOfSpeech: .verb,
                exampleSentence: v.3,
                exampleTranslation: v.4,
                frequencyRank: v.5,
                difficultyTier: v.6,
                conjugations: v.7,
                article: nil
            ))
        }

        // ADJECTIVES - High frequency Brazilian Portuguese
        let adjectives: [(String, String, String, String, String, Int, DifficultyTier)] = [
            ("bom", "good", "ˈbõ", "O livro é muito bom.", "The book is very good.", 50, .beginner),
            ("grande", "big/large", "ˈɡɾɐ̃.dʒi", "A cidade é grande.", "The city is big.", 52, .beginner),
            ("novo", "new/young", "ˈno.vu", "Comprei um carro novo.", "I bought a new car.", 54, .beginner),
            ("primeiro", "first", "pɾi.ˈmej.ɾu", "Este é o primeiro dia.", "This is the first day.", 56, .beginner),
            ("último", "last", "ˈuw.tʃi.mu", "Este é o último dia.", "This is the last day.", 58, .beginner),
            ("longo", "long", "ˈlõ.ɡu", "O caminho é longo.", "The path is long.", 60, .beginner),
            ("mesmo", "same", "ˈmez.mu", "É a mesma coisa.", "It's the same thing.", 62, .beginner),
            ("pequeno", "small", "pe.ˈke.nu", "A casa é pequena.", "The house is small.", 64, .beginner),
            ("bonito", "beautiful/pretty", "bo.ˈni.tu", "O pôr do sol é bonito.", "The sunset is beautiful.", 66, .beginner),
            ("velho", "old", "ˈvɛ.ʎu", "O prédio é muito velho.", "The building is very old.", 68, .beginner),
            ("importante", "important", "ĩ.poɾ.ˈtɐ̃.tʃi", "Isso é muito importante.", "This is very important.", 70, .beginner),
            ("diferente", "different", "dʒi.fe.ˈɾẽ.tʃi", "Cada pessoa é diferente.", "Each person is different.", 72, .beginner),
            ("possível", "possible", "po.ˈsi.vew", "Tudo é possível.", "Everything is possible.", 74, .beginner),
            ("melhor", "better/best", "me.ˈʎoɾ", "Este é o melhor restaurante.", "This is the best restaurant.", 76, .beginner),
            ("pior", "worse/worst", "pi.ˈoɾ", "Esta é a pior situação.", "This is the worst situation.", 78, .beginner),
            ("feliz", "happy", "fe.ˈlis", "Estou muito feliz.", "I am very happy.", 80, .beginner),
            ("triste", "sad", "ˈtɾis.tʃi", "Ele está triste.", "He is sad.", 82, .beginner),
            ("fácil", "easy", "ˈfa.siw", "O exercício é fácil.", "The exercise is easy.", 84, .beginner),
            ("difícil", "difficult", "dʒi.ˈfi.siw", "A prova é difícil.", "The test is difficult.", 86, .beginner),
            ("certo", "right/certain", "ˈsɛɾ.tu", "Você está certo.", "You are right.", 88, .beginner),
            ("rápido", "fast/quick", "ˈʁa.pi.du", "O trem é rápido.", "The train is fast.", 90, .beginner),
            ("lento", "slow", "ˈlẽ.tu", "O processo é lento.", "The process is slow.", 92, .elementary),
            ("quente", "hot", "ˈkẽ.tʃi", "O café está quente.", "The coffee is hot.", 94, .beginner),
            ("frio", "cold", "ˈfɾi.u", "O inverno é frio.", "Winter is cold.", 96, .beginner),
            ("caro", "expensive", "ˈka.ɾu", "O restaurante é caro.", "The restaurant is expensive.", 98, .beginner),
            ("barato", "cheap", "ba.ˈɾa.tu", "A comida é barata.", "The food is cheap.", 100, .beginner),
            ("rico", "rich", "ˈʁi.ku", "O homem é rico.", "The man is rich.", 102, .beginner),
            ("pobre", "poor", "ˈpɔ.bɾi", "A família é pobre.", "The family is poor.", 104, .beginner),
            ("forte", "strong", "ˈfɔɾ.tʃi", "Ele é muito forte.", "He is very strong.", 106, .beginner),
            ("fraco", "weak", "ˈfɾa.ku", "O sinal é fraco.", "The signal is weak.", 108, .elementary),
            ("limpo", "clean", "ˈlĩ.pu", "A casa está limpa.", "The house is clean.", 110, .beginner),
            ("sujo", "dirty", "ˈsu.ʒu", "O chão está sujo.", "The floor is dirty.", 112, .beginner),
            ("aberto", "open", "a.ˈbɛɾ.tu", "A loja está aberta.", "The store is open.", 114, .beginner),
            ("fechado", "closed", "fe.ˈʃa.du", "O banco está fechado.", "The bank is closed.", 116, .beginner),
            ("inteiro", "whole/entire", "ĩ.ˈtej.ɾu", "Comi o bolo inteiro.", "I ate the whole cake.", 118, .elementary),
            ("próximo", "next/near", "ˈpɾɔ.si.mu", "O próximo passo é fácil.", "The next step is easy.", 120, .elementary),
            ("pronto", "ready", "ˈpɾõ.tu", "O jantar está pronto.", "Dinner is ready.", 122, .beginner),
            ("seguro", "safe/secure", "se.ˈɡu.ɾu", "Este lugar é seguro.", "This place is safe.", 124, .elementary),
            ("livre", "free", "ˈli.vɾi", "Amanhã estou livre.", "Tomorrow I'm free.", 126, .beginner),
            ("interessante", "interesting", "ĩ.te.ɾe.ˈsɐ̃.tʃi", "O filme é interessante.", "The movie is interesting.", 128, .elementary),
            ("necessário", "necessary", "ne.se.ˈsa.ɾi.u", "Isso é necessário.", "This is necessary.", 130, .intermediate),
            ("simples", "simple", "ˈsĩ.plis", "A solução é simples.", "The solution is simple.", 132, .elementary),
            ("tranquilo", "calm/peaceful", "tɾɐ̃.ˈki.lu", "Fique tranquilo.", "Stay calm.", 134, .elementary),
            ("cheio", "full", "ˈʃej.u", "O restaurante está cheio.", "The restaurant is full.", 136, .beginner),
            ("vazio", "empty", "va.ˈzi.u", "A garrafa está vazia.", "The bottle is empty.", 138, .beginner),
            ("alto", "tall/high", "ˈaw.tu", "O prédio é alto.", "The building is tall.", 140, .beginner),
            ("baixo", "short/low", "ˈbaj.ʃu", "O preço é baixo.", "The price is low.", 142, .beginner),
            ("claro", "clear/light", "ˈkla.ɾu", "A água é clara.", "The water is clear.", 144, .beginner),
            ("escuro", "dark", "is.ˈku.ɾu", "O quarto está escuro.", "The room is dark.", 146, .beginner),
            ("doce", "sweet", "ˈdo.si", "O bolo é doce.", "The cake is sweet.", 148, .beginner),
            ("salgado", "salty/savory", "saw.ˈɡa.du", "A comida está salgada.", "The food is salty.", 150, .elementary),
            ("pesado", "heavy", "pe.ˈza.du", "A mala é pesada.", "The suitcase is heavy.", 152, .elementary),
            ("leve", "light (weight)", "ˈlɛ.vi", "A bolsa é leve.", "The bag is light.", 154, .elementary),
            ("seco", "dry", "ˈse.ku", "O clima é seco.", "The climate is dry.", 156, .elementary),
            ("molhado", "wet", "mo.ˈʎa.du", "A roupa está molhada.", "The clothes are wet.", 158, .elementary),
            ("perfeito", "perfect", "peɾ.ˈfej.tu", "O momento é perfeito.", "The moment is perfect.", 160, .elementary),
            ("verdadeiro", "true/real", "veɾ.da.ˈdej.ɾu", "Um amigo verdadeiro.", "A true friend.", 162, .intermediate),
            ("comum", "common", "ko.ˈmũ", "Isso é muito comum.", "This is very common.", 164, .elementary),
            ("estranho", "strange", "is.ˈtɾɐ̃.ɲu", "Que barulho estranho.", "What a strange noise.", 166, .elementary),
            ("cansado", "tired", "kɐ̃.ˈsa.du", "Estou muito cansado.", "I am very tired.", 168, .beginner),
            ("ocupado", "busy", "o.ku.ˈpa.du", "Estou ocupado agora.", "I'm busy now.", 170, .elementary),
            ("delicioso", "delicious", "de.li.si.ˈo.zu", "A comida está deliciosa.", "The food is delicious.", 172, .elementary),
            ("gentil", "kind", "ʒẽ.ˈtʃiw", "Ela é muito gentil.", "She is very kind.", 174, .elementary),
            ("inteligente", "intelligent", "ĩ.te.li.ˈʒẽ.tʃi", "O aluno é inteligente.", "The student is intelligent.", 176, .elementary),
            ("saudável", "healthy", "saw.ˈda.vew", "Comer bem é saudável.", "Eating well is healthy.", 178, .intermediate),
            ("perigoso", "dangerous", "pe.ɾi.ˈɡo.zu", "O lugar é perigoso.", "The place is dangerous.", 180, .intermediate),
            ("silencioso", "quiet/silent", "si.lẽ.si.ˈo.zu", "A noite está silenciosa.", "The night is quiet.", 182, .intermediate),
            ("orgulhoso", "proud", "oɾ.ɡu.ˈʎo.zu", "Estou orgulhoso de você.", "I'm proud of you.", 184, .intermediate),
            ("preocupado", "worried", "pɾe.o.ku.ˈpa.du", "Estou preocupado com ele.", "I'm worried about him.", 186, .intermediate),
            ("maravilhoso", "wonderful", "ma.ɾa.vi.ˈʎo.zu", "O dia foi maravilhoso.", "The day was wonderful.", 188, .intermediate),
        ]

        for (i, a) in adjectives.enumerated() {
            allWords.append(Word(
                id: "adj_\(i)",
                portuguese: a.0,
                english: a.1,
                ipa: a.2,
                partOfSpeech: .adjective,
                exampleSentence: a.3,
                exampleTranslation: a.4,
                frequencyRank: a.5,
                difficultyTier: a.6,
                conjugations: nil,
                article: nil
            ))
        }

        self.words = allWords
    }

    func nouns(tier: DifficultyTier? = nil) -> [Word] {
        let filtered = words.filter { $0.partOfSpeech == .noun }
        guard let tier else { return filtered }
        return filtered.filter { $0.difficultyTier <= tier }
    }

    func verbs(tier: DifficultyTier? = nil) -> [Word] {
        let filtered = words.filter { $0.partOfSpeech == .verb }
        guard let tier else { return filtered }
        return filtered.filter { $0.difficultyTier <= tier }
    }

    func adjectives(tier: DifficultyTier? = nil) -> [Word] {
        let filtered = words.filter { $0.partOfSpeech == .adjective }
        guard let tier else { return filtered }
        return filtered.filter { $0.difficultyTier <= tier }
    }

    func word(byId id: String) -> Word? {
        words.first { $0.id == id }
    }
}
