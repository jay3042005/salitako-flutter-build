import '../models/practice_mode.dart';

/// Reading passage with full text content
class ReadingPassage {
  final String id;
  final String title;
  final String category;
  final String content;
  final int wordCount;
  final Difficulty difficulty;
  final Language language;

  const ReadingPassage({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.wordCount,
    required this.difficulty,
    required this.language,
  });
}

/// Pre-defined reading passages
class ReadingPassages {
  // ===== ENGLISH PASSAGES =====
  
  static const List<ReadingPassage> englishEasy = [
    ReadingPassage(
      id: 'en_easy_1',
      title: 'My Morning Routine',
      category: 'Daily Life',
      content: '''Every morning, I wake up at six o'clock. First, I brush my teeth and wash my face. Then, I eat a simple breakfast with rice and eggs. After eating, I take a shower and get dressed for work. I leave the house at seven thirty. The bus stop is just a short walk from my home. I enjoy looking out the window during the ride. It helps me feel ready for the day ahead.''',
      wordCount: 78,
      difficulty: Difficulty.easy,
      language: Language.english,
    ),
    ReadingPassage(
      id: 'en_easy_2',
      title: 'The Friendly Dog',
      category: 'Story',
      content: '''Max is a golden retriever. He lives with the Santos family in a small house. Every day, Max waits by the door for the children to come home from school. When they arrive, he wags his tail and jumps with joy. The children love to play fetch with Max in the backyard. He is not just a pet. He is part of the family.''',
      wordCount: 68,
      difficulty: Difficulty.easy,
      language: Language.english,
    ),
    ReadingPassage(
      id: 'en_easy_3',
      title: 'A Rainy Day',
      category: 'Weather',
      content: '''The rain started falling early this morning. Big drops hit the windows and made a soft sound. I decided to stay inside and read a book. My cat sat next to me on the couch. We watched the rain together. The streets were empty, but the plants looked happy. Rain brings life to our gardens. I made hot chocolate and enjoyed the peaceful day.''',
      wordCount: 67,
      difficulty: Difficulty.easy,
      language: Language.english,
    ),
  ];

  static const List<ReadingPassage> englishMedium = [
    ReadingPassage(
      id: 'en_med_1',
      title: 'The Rise of Electric Vehicles',
      category: 'Technology',
      content: '''Electric vehicles are becoming increasingly popular around the world. Unlike traditional cars that run on gasoline, electric vehicles use batteries to power their motors. This makes them better for the environment because they produce zero emissions while driving. Many countries are now offering incentives to encourage people to switch to electric cars. Charging stations are being built in cities and along highways. While the initial cost of an electric vehicle may be higher, owners save money on fuel and maintenance over time. Experts predict that by 2030, electric vehicles will make up a significant portion of all cars on the road.''',
      wordCount: 102,
      difficulty: Difficulty.medium,
      language: Language.english,
    ),
    ReadingPassage(
      id: 'en_med_2',
      title: 'The Importance of Sleep',
      category: 'Health',
      content: '''Getting enough sleep is essential for both physical and mental health. During sleep, our bodies repair tissues, consolidate memories, and release hormones that regulate growth and appetite. Adults typically need seven to nine hours of sleep per night, while teenagers require even more. Unfortunately, many people struggle with sleep due to stress, technology use, or irregular schedules. Poor sleep can lead to decreased concentration, weakened immune function, and increased risk of chronic diseases. Experts recommend establishing a consistent bedtime routine, limiting screen time before bed, and creating a comfortable sleep environment to improve sleep quality.''',
      wordCount: 98,
      difficulty: Difficulty.medium,
      language: Language.english,
    ),
  ];

  static const List<ReadingPassage> englishHard = [
    ReadingPassage(
      id: 'en_hard_1',
      title: 'Artificial Intelligence Ethics',
      category: 'Technology',
      content: '''The rapid advancement of artificial intelligence has raised significant ethical questions that society must address. As AI systems become more sophisticated, concerns about privacy, bias, and job displacement have intensified. Machine learning algorithms trained on historical data may perpetuate existing societal biases, leading to discriminatory outcomes in areas such as hiring, lending, and criminal justice. Furthermore, the development of autonomous weapons and surveillance technologies poses unprecedented challenges to human rights and international security. Researchers and policymakers are working to establish frameworks for responsible AI development, emphasizing transparency, accountability, and human oversight. The balance between innovation and ethical considerations will shape the future of this transformative technology.''',
      wordCount: 109,
      difficulty: Difficulty.hard,
      language: Language.english,
    ),
  ];

  // ===== FILIPINO PASSAGES =====
  
  static const List<ReadingPassage> filipinoEasy = [
    ReadingPassage(
      id: 'fil_easy_1',
      title: 'Ang Aking Pamilya',
      category: 'Pamilya',
      content: '''Ang aking pamilya ay may limang miyembro. Si Tatay ay nagtatrabaho sa opisina. Si Nanay ay guro sa elementarya. Ako ay may dalawang kapatid. Si Kuya ay nasa kolehiyo at si Ate ay nasa hayskul. Tuwing Linggo, sama-sama kaming kumakain ng almusal. Nagkukuwentuhan kami tungkol sa nakaraang linggo. Masaya ako sa aking pamilya. Mahal ko silang lahat.''',
      wordCount: 58,
      difficulty: Difficulty.easy,
      language: Language.filipino,
    ),
    ReadingPassage(
      id: 'fil_easy_2',
      title: 'Sa Palengke',
      category: 'Pamumuhay',
      content: '''Tuwing Sabado, pumupunta kami ni Nanay sa palengke. Maraming tao at maingay. Bumibili kami ng gulay, isda, at karne. Mura ang presyo ng mga prutas kapag maaga. Hinahanap ko ang paborito kong mangga. Pagkatapos mamili, kumakain kami ng lugaw. Mainit at masarap ito. Pagkatapos, uuwi na kami at magluluto ng tanghalian.''',
      wordCount: 52,
      difficulty: Difficulty.easy,
      language: Language.filipino,
    ),
    ReadingPassage(
      id: 'fil_easy_3',
      title: 'Ang Aso Kong si Bantay',
      category: 'Hayop',
      content: '''Si Bantay ang pangalan ng aso ko. Siya ay asong askal na kulay kayumanggi. Araw-araw, binabantayan niya ang aming bahay. Kapag umaga, tumatakbo siya sa bakuran. Mahilig siyang maglaro ng bola. Pinapakain ko siya ng kanin at isda. Tapat at mabait si Bantay. Siya ang pinakamabuting kaibigan ko.''',
      wordCount: 50,
      difficulty: Difficulty.easy,
      language: Language.filipino,
    ),
  ];

  static const List<ReadingPassage> filipinoMedium = [
    ReadingPassage(
      id: 'fil_med_1',
      title: 'Ang Kahalagahan ng Edukasyon',
      category: 'Edukasyon',
      content: '''Ang edukasyon ay isa sa pinakamahalagang bagay na maaaring makamit ng isang tao. Sa pamamagitan ng pag-aaral, natututo tayo ng mga kasanayan at kaalaman na makakatulong sa ating kinabukasan. Hindi lamang ito tungkol sa pagkuha ng mataas na grado kundi pati na rin sa pagkatuto kung paano makisama sa kapwa at harapin ang mga hamon sa buhay. Ang mga magulang at guro ay gumagabay sa atin upang maging responsableng mamamayan. Sa panahon ngayon, mas maraming pagkakataon ang bukas para sa mga taong may magandang edukasyon. Kaya naman, dapat nating pahalagahan ang bawat araw sa paaralan.''',
      wordCount: 95,
      difficulty: Difficulty.medium,
      language: Language.filipino,
    ),
    ReadingPassage(
      id: 'fil_med_2',
      title: 'Mga Tradisyon sa Pasko',
      category: 'Kultura',
      content: '''Ang Pasko sa Pilipinas ay isa sa pinakamahabang selebrasyon sa buong mundo. Nagsisimula ito sa unang araw ng Setyembre at nagtatapos sa Pista ng Tatlong Hari. Ang mga Pilipino ay kilala sa makulay na parol at magagandang ilaw na nagpapalamuti sa mga bahay at kalsada. Isang mahalagang tradisyon ang Simbang Gabi, ang siyam na araw ng misa bago ang Pasko. Pagkatapos ng misa, nagtitipon ang mga pamilya upang kumain ng puto bumbong at bibingka. Sa Noche Buena, naghahanda ng masasarap na pagkain tulad ng lechon, ham, at queso de bola. Ang Pasko ay panahon ng pagbibigayan at pagmamahalan.''',
      wordCount: 107,
      difficulty: Difficulty.medium,
      language: Language.filipino,
    ),
  ];

  static const List<ReadingPassage> filipinoHard = [
    ReadingPassage(
      id: 'fil_hard_1',
      title: 'Ang Pagbabago ng Klima',
      category: 'Kalikasan',
      content: '''Ang pagbabago ng klima ay isa sa pinakamalalaking hamon na kinakaharap ng sangkatauhan sa kasalukuyan. Dahil sa labis na paggamit ng fossil fuels at pagkasira ng mga kagubatan, tumataas ang temperatura ng mundo. Ang epekto nito ay makikita sa pagtaas ng antas ng dagat, mas malakas na bagyo, at pagbabago sa pattern ng panahon. Para sa isang bansang archipelago tulad ng Pilipinas, ang mga epektong ito ay nakababahala. Maraming komunidad sa baybaying dagat ang nanganganib na malunod. Kinakailangan ang sama-samang aksyon ng gobyerno, pribadong sektor, at mga mamamayan upang mabawasan ang carbon emissions at maprotektahan ang ating kalikasan para sa susunod na henerasyon.''',
      wordCount: 108,
      difficulty: Difficulty.hard,
      language: Language.filipino,
    ),
  ];

  // ===== TAGLISH PASSAGES =====
  
  static const List<ReadingPassage> taglishEasy = [
    ReadingPassage(
      id: 'tl_easy_1',
      title: 'My First Job Interview',
      category: 'Work Life',
      content: '''Kahapon, nagkaroon ako ng first job interview ko. Sobrang kaba ako! Nag-prepare ako ng resume ko at nag-practice ng possible questions. Pagdating ko sa office, friendly naman ang receptionist. Hinintay ko ang turn ko for about fifteen minutes. Nang tawagin na ako, deep breath muna bago pumasok. Thankfully, mabait ang interviewer. Na-explain ko naman ng maayos ang qualifications ko. Sana ma-hire ako!''',
      wordCount: 63,
      difficulty: Difficulty.easy,
      language: Language.taglish,
    ),
    ReadingPassage(
      id: 'tl_easy_2',
      title: 'Weekend Plans',
      category: 'Daily Life',
      content: '''Excited na ako for the weekend! Plano naming mag-mall ng friends ko this Saturday. Gusto naming manood ng bagong Marvel movie. After that, kakain kami ng samgyupsal. Yummy! On Sunday naman, stay-at-home day ko. Magre-rest lang ako at manonood ng series sa Netflix. Kailangan ko ring mag-aral for Monday\'s exam. Pero for now, let me enjoy muna ang remaining days ng week.''',
      wordCount: 66,
      difficulty: Difficulty.easy,
      language: Language.taglish,
    ),
  ];

  static const List<ReadingPassage> taglishMedium = [
    ReadingPassage(
      id: 'tl_med_1',
      title: 'Balancing Work and Life',
      category: 'Career',
      content: '''Mahirap talaga mag-balance ng work at personal life, lalo na kung WFH setup ang work mo. Minsan, di mo na alam kung kelan ang work hours at kelan ang rest time. Importante na mag-set tayo ng boundaries. For example, pagka-5 PM na, dapat i-close na ang laptop at i-mute ang work notifications. Kailangan din ng dedicated workspace sa bahay para mentally, nase-separate mo ang work mode at chill mode. Exercise is also important para ma-release ang stress. Kahit thirty-minute walk lang sa labas, malaking tulong na \'yon. At syempre, quality time with family and friends should not be sacrificed. Remember, we work to live, not live to work.''',
      wordCount: 114,
      difficulty: Difficulty.medium,
      language: Language.taglish,
    ),
  ];

  /// Get passages by language and difficulty
  static List<ReadingPassage> getPassages(Language language, Difficulty difficulty) {
    switch (language) {
      case Language.english:
        switch (difficulty) {
          case Difficulty.easy:
            return englishEasy;
          case Difficulty.medium:
            return englishMedium;
          case Difficulty.hard:
            return englishHard;
        }
      case Language.filipino:
        switch (difficulty) {
          case Difficulty.easy:
            return filipinoEasy;
          case Difficulty.medium:
            return filipinoMedium;
          case Difficulty.hard:
            return filipinoHard;
        }
      case Language.taglish:
        switch (difficulty) {
          case Difficulty.easy:
            return taglishEasy;
          case Difficulty.medium:
            return taglishMedium;
          case Difficulty.hard:
            return taglishMedium; // Fallback to medium for now
        }
    }
  }

  /// Get all passages for a language
  static List<ReadingPassage> getAllForLanguage(Language language) {
    switch (language) {
      case Language.english:
        return [...englishEasy, ...englishMedium, ...englishHard];
      case Language.filipino:
        return [...filipinoEasy, ...filipinoMedium, ...filipinoHard];
      case Language.taglish:
        return [...taglishEasy, ...taglishMedium];
    }
  }
}
