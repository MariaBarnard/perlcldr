#!/usr/bin/perl
# Do not normalise this test file. It has deliberately unnormalised characters in it.
use v5.10;
use strict;
use warnings;
use utf8;
use if $^V ge v5.12.0, feature => 'unicode_strings';

use Test::More tests => 25;
use Test::Exception;

use ok 'Locale::CLDR';

my $locale = Locale::CLDR->new('en_GB');
my $other_locale = Locale::CLDR->new('en_NZ');

is($locale->locale_name(), 'British English', 'Locale name from current locale');
is($locale->locale_name('fr_CA'), 'Canadian French', 'Locale name from string');
is($locale->locale_name($other_locale), 'English (New Zealand)', 'Locale name from other locale object');

is($locale->language_name(), 'English', 'Language name from current locale');
is($locale->language_name('fr'), 'French', 'Language name from string');
is($locale->language_name($other_locale), 'English', 'Language name from other locale object');

my $all_languages = {
    'aa' => 'Afar',
	'ab' => 'Abkhazian',
	'ace' => 'Achinese',
	'ach' => 'Acoli',
	'ada' => 'Adangme',
	'ady' => 'Adyghe',
	'ae' => 'Avestan',
	'aeb' => 'Tunisian Arabic',
	'af' => 'Afrikaans',
	'afh' => 'Afrihili',
	'agq' => 'Aghem',
	'ain' => 'Ainu',
	'ak' => 'Akan',
	'akk' => 'Akkadian',
	'akz' => 'Alabama',
	'ale' => 'Aleut',
	'aln' => 'Gheg Albanian',
	'alt' => 'Southern Altai',
	'am' => 'Amharic',
	'an' => 'Aragonese',
	'ang' => 'Old English',
	'anp' => 'Angika',
	'ar' => 'Arabic',
	'ar_001' => 'Modern Standard Arabic',
	'arc' => 'Aramaic',
	'arn' => 'Mapuche',
	'aro' => 'Araona',
	'arp' => 'Arapaho',
	'arq' => 'Algerian Arabic',
	'arw' => 'Arawak',
	'ary' => 'Moroccan Arabic',
	'arz' => 'Egyptian Arabic',
	'as' => 'Assamese',
	'asa' => 'Asu',
	'ase' => 'American Sign Language',
	'ast' => 'Asturian',
	'av' => 'Avaric',
	'avk' => 'Kotava',
	'awa' => 'Awadhi',
	'ay' => 'Aymara',
	'az' => 'Azerbaijani',
	'az@alt=short' => 'Azeri',
	'azb' => 'South Azerbaijani',
	'ba' => 'Bashkir',
	'bal' => 'Baluchi',
	'ban' => 'Balinese',
	'bar' => 'Bavarian',
	'bas' => 'Basaa',
	'bax' => 'Bamun',
	'bbc' => 'Batak Toba',
	'bbj' => 'Ghomala',
	'be' => 'Belarusian',
	'bej' => 'Beja',
	'bem' => 'Bemba',
	'bew' => 'Betawi',
	'bez' => 'Bena',
	'bfd' => 'Bafut',
	'bfq' => 'Badaga',
	'bg' => 'Bulgarian',
	'bho' => 'Bhojpuri',
	'bi' => 'Bislama',
	'bik' => 'Bikol',
	'bin' => 'Bini',
	'bjn' => 'Banjar',
	'bkm' => 'Kom',
	'bla' => 'Siksika',
	'bm' => 'Bambara',
	'bn' => 'Bengali',
	'bo' => 'Tibetan',
	'bpy' => 'Bishnupriya',
	'bqi' => 'Bakhtiari',
	'br' => 'Breton',
	'bra' => 'Braj',
	'brh' => 'Brahui',
	'brx' => 'Bodo',
	'bs' => 'Bosnian',
	'bss' => 'Akoose',
	'bua' => 'Buriat',
	'bug' => 'Buginese',
	'bum' => 'Bulu',
	'byn' => 'Blin',
	'byv' => 'Medumba',
	'ca' => 'Catalan',
	'cad' => 'Caddo',
	'car' => 'Carib',
	'cay' => 'Cayuga',
	'cch' => 'Atsam',
	'ce' => 'Chechen',
	'ceb' => 'Cebuano',
	'cgg' => 'Chiga',
	'ch' => 'Chamorro',
	'chb' => 'Chibcha',
	'chg' => 'Chagatai',
	'chk' => 'Chuukese',
	'chm' => 'Mari',
	'chn' => 'Chinook Jargon',
	'cho' => 'Choctaw',
	'chp' => 'Chipewyan',
	'chr' => 'Cherokee',
	'chy' => 'Cheyenne',
	'ckb' => 'Sorani Kurdish',
	'co' => 'Corsican',
	'cop' => 'Coptic',
	'cps' => 'Capiznon',
	'cr' => 'Cree',
	'crh' => 'Crimean Turkish',
	'cs' => 'Czech',
	'csb' => 'Kashubian',
	'cu' => 'Church Slavic',
	'cv' => 'Chuvash',
	'cy' => 'Welsh',
	'da' => 'Danish',
	'dak' => 'Dakota',
	'dar' => 'Dargwa',
	'dav' => 'Taita',
	'de' => 'German',
	'de_AT' => 'Austrian German',
	'de_CH' => 'Swiss High German',
	'del' => 'Delaware',
	'den' => 'Slave',
	'dgr' => 'Dogrib',
	'din' => 'Dinka',
	'dje' => 'Zarma',
	'doi' => 'Dogri',
	'dsb' => 'Lower Sorbian',
	'dtp' => 'Central Dusun',
	'dua' => 'Duala',
	'dum' => 'Middle Dutch',
	'dv' => 'Divehi',
	'dyo' => 'Jola-Fonyi',
	'dyu' => 'Dyula',
	'dz' => 'Dzongkha',
	'dzg' => 'Dazaga',
	'ebu' => 'Embu',
	'ee' => 'Ewe',
	'efi' => 'Efik',
	'egl' => 'Emilian',
	'egy' => 'Ancient Egyptian',
	'eka' => 'Ekajuk',
	'el' => 'Greek',
	'elx' => 'Elamite',
	'en' => 'English',
	'en_AU' => 'Australian English',
	'en_CA' => 'Canadian English',
	'en_GB' => 'British English',
	'en_GB@alt=short' => 'UK English',
	'en_US' => 'American English',
	'en_US@alt=short' => 'US English',
	'enm' => 'Middle English',
	'eo' => 'Esperanto',
	'es' => 'Spanish',
	'es_419' => 'Latin American Spanish',
	'es_ES' => 'European Spanish',
	'es_MX' => 'Mexican Spanish',
	'esu' => 'Central Yupik',
	'et' => 'Estonian',
	'eu' => 'Basque',
	'ewo' => 'Ewondo',
	'ext' => 'Extremaduran',
	'fa' => 'Persian',
	'fan' => 'Fang',
	'fat' => 'Fanti',
	'ff' => 'Fulah',
	'fi' => 'Finnish',
	'fil' => 'Filipino',
	'fit' => 'Tornedalen Finnish',
	'fj' => 'Fijian',
	'fo' => 'Faroese',
	'fon' => 'Fon',
	'fr' => 'French',
	'fr_CA' => 'Canadian French',
	'fr_CH' => 'Swiss French',
	'frc' => 'Cajun French',
	'frm' => 'Middle French',
	'fro' => 'Old French',
	'frp' => 'Arpitan',
	'frr' => 'Northern Frisian',
	'frs' => 'Eastern Frisian',
	'fur' => 'Friulian',
	'fy' => 'Western Frisian',
	'ga' => 'Irish',
	'gaa' => 'Ga',
	'gag' => 'Gagauz',
	'gan' => 'Gan Chinese',
	'gay' => 'Gayo',
	'gba' => 'Gbaya',
	'gbz' => 'Zoroastrian Dari',
	'gd' => 'Scottish Gaelic',
	'gez' => 'Geez',
	'gil' => 'Gilbertese',
	'gl' => 'Galician',
	'glk' => 'Gilaki',
	'gmh' => 'Middle High German',
	'gn' => 'Guarani',
	'goh' => 'Old High German',
	'gom' => 'Goan Konkani',
	'gon' => 'Gondi',
	'gor' => 'Gorontalo',
	'got' => 'Gothic',
	'grb' => 'Grebo',
	'grc' => 'Ancient Greek',
	'gsw' => 'Swiss German',
	'gu' => 'Gujarati',
	'guc' => 'Wayuu',
	'gur' => 'Frafra',
	'guz' => 'Gusii',
	'gv' => 'Manx',
	'gwi' => 'Gwichʼin',
	'ha' => 'Hausa',
	'hai' => 'Haida',
	'hak' => 'Hakka Chinese',
	'haw' => 'Hawaiian',
	'he' => 'Hebrew',
	'hi' => 'Hindi',
	'hif' => 'Fiji Hindi',
	'hil' => 'Hiligaynon',
	'hit' => 'Hittite',
	'hmn' => 'Hmong',
	'ho' => 'Hiri Motu',
	'hr' => 'Croatian',
	'hsb' => 'Upper Sorbian',
	'hsn' => 'Xiang Chinese',
	'ht' => 'Haitian',
	'hu' => 'Hungarian',
	'hup' => 'Hupa',
	'hy' => 'Armenian',
	'hz' => 'Herero',
	'ia' => 'Interlingua',
	'iba' => 'Iban',
	'ibb' => 'Ibibio',
	'id' => 'Indonesian',
	'ie' => 'Interlingue',
	'ig' => 'Igbo',
	'ii' => 'Sichuan Yi',
	'ik' => 'Inupiaq',
	'ilo' => 'Iloko',
	'inh' => 'Ingush',
	'io' => 'Ido',
	'is' => 'Icelandic',
	'it' => 'Italian',
	'iu' => 'Inuktitut',
	'izh' => 'Ingrian',
	'ja' => 'Japanese',
	'jam' => 'Jamaican Creole English',
	'jbo' => 'Lojban',
	'jgo' => 'Ngomba',
	'jmc' => 'Machame',
	'jpr' => 'Judeo-Persian',
	'jrb' => 'Judeo-Arabic',
	'jut' => 'Jutish',
	'jv' => 'Javanese',
	'ka' => 'Georgian',
	'kaa' => 'Kara-Kalpak',
	'kab' => 'Kabyle',
	'kac' => 'Kachin',
	'kaj' => 'Jju',
	'kam' => 'Kamba',
	'kaw' => 'Kawi',
	'kbd' => 'Kabardian',
	'kbl' => 'Kanembu',
	'kcg' => 'Tyap',
	'kde' => 'Makonde',
	'kea' => 'Kabuverdianu',
	'ken' => 'Kenyang',
	'kfo' => 'Koro',
	'kg' => 'Kongo',
	'kgp' => 'Kaingang',
	'kha' => 'Khasi',
	'kho' => 'Khotanese',
	'khq' => 'Koyra Chiini',
	'khw' => 'Khowar',
	'ki' => 'Kikuyu',
	'kiu' => 'Kirmanjki',
	'kj' => 'Kuanyama',
	'kk' => 'Kazakh',
	'kkj' => 'Kako',
	'kl' => 'Kalaallisut',
	'kln' => 'Kalenjin',
	'km' => 'Khmer',
	'kmb' => 'Kimbundu',
	'kn' => 'Kannada',
	'ko' => 'Korean',
	'koi' => 'Komi-Permyak',
	'kok' => 'Konkani',
	'kos' => 'Kosraean',
	'kpe' => 'Kpelle',
	'kr' => 'Kanuri',
	'krc' => 'Karachay-Balkar',
	'kri' => 'Krio',
	'krj' => 'Kinaray-a',
	'krl' => 'Karelian',
	'kru' => 'Kurukh',
	'ks' => 'Kashmiri',
	'ksb' => 'Shambala',
	'ksf' => 'Bafia',
	'ksh' => 'Colognian',
	'ku' => 'Kurdish',
	'kum' => 'Kumyk',
	'kut' => 'Kutenai',
	'kv' => 'Komi',
	'kw' => 'Cornish',
	'ky' => 'Kyrgyz',
	'ky@alt=variant' => 'Kirghiz',
	'la' => 'Latin',
	'lad' => 'Ladino',
	'lag' => 'Langi',
	'lah' => 'Lahnda',
	'lam' => 'Lamba',
	'lb' => 'Luxembourgish',
	'lez' => 'Lezghian',
	'lfn' => 'Lingua Franca Nova',
	'lg' => 'Ganda',
	'li' => 'Limburgish',
	'lij' => 'Ligurian',
	'liv' => 'Livonian',
	'lkt' => 'Lakota',
	'lmo' => 'Lombard',
	'ln' => 'Lingala',
	'lo' => 'Lao',
	'lol' => 'Mongo',
	'loz' => 'Lozi',
	'lt' => 'Lithuanian',
	'ltg' => 'Latgalian',
	'lu' => 'Luba-Katanga',
	'lua' => 'Luba-Lulua',
	'lui' => 'Luiseno',
	'lun' => 'Lunda',
	'luo' => 'Luo',
	'lus' => 'Mizo',
	'luy' => 'Luyia',
	'lv' => 'Latvian',
	'lzh' => 'Literary Chinese',
	'lzz' => 'Laz',
	'mad' => 'Madurese',
	'maf' => 'Mafa',
	'mag' => 'Magahi',
	'mai' => 'Maithili',
	'mak' => 'Makasar',
	'man' => 'Mandingo',
	'mas' => 'Masai',
	'mde' => 'Maba',
	'mdf' => 'Moksha',
	'mdr' => 'Mandar',
	'men' => 'Mende',
	'mer' => 'Meru',
	'mfe' => 'Morisyen',
	'mg' => 'Malagasy',
	'mga' => 'Middle Irish',
	'mgh' => 'Makhuwa-Meetto',
	'mgo' => 'Metaʼ',
	'mh' => 'Marshallese',
	'mi' => 'Maori',
	'mic' => 'Micmac',
	'min' => 'Minangkabau',
	'mk' => 'Macedonian',
	'ml' => 'Malayalam',
	'mn' => 'Mongolian',
	'mnc' => 'Manchu',
	'mni' => 'Manipuri',
	'moh' => 'Mohawk',
	'mos' => 'Mossi',
	'mr' => 'Marathi',
	'mrj' => 'Western Mari',
	'ms' => 'Malay',
	'mt' => 'Maltese',
	'mua' => 'Mundang',
	'mul' => 'Multiple Languages',
	'mus' => 'Creek',
	'mwl' => 'Mirandese',
	'mwr' => 'Marwari',
	'mwv' => 'Mentawai',
	'my' => 'Burmese',
	'mye' => 'Myene',
	'myv' => 'Erzya',
	'mzn' => 'Mazanderani',
	'na' => 'Nauru',
	'nan' => 'Min Nan Chinese',
	'nap' => 'Neapolitan',
	'naq' => 'Nama',
	'nb' => 'Norwegian Bokmål',
	'nd' => 'North Ndebele',
	'nds' => 'Low German',
	'ne' => 'Nepali',
	'new' => 'Newari',
	'ng' => 'Ndonga',
	'nia' => 'Nias',
	'niu' => 'Niuean',
	'njo' => 'Ao Naga',
	'nl' => 'Dutch',
	'nl_BE' => 'Flemish',
	'nmg' => 'Kwasio',
	'nn' => 'Norwegian Nynorsk',
	'nnh' => 'Ngiemboon',
	'no' => 'Norwegian',
	'nog' => 'Nogai',
	'non' => 'Old Norse',
	'nov' => 'Novial',
	'nqo' => 'NʼKo',
	'nr' => 'South Ndebele',
	'nso' => 'Northern Sotho',
	'nus' => 'Nuer',
	'nv' => 'Navajo',
	'nwc' => 'Classical Newari',
	'ny' => 'Nyanja',
	'nym' => 'Nyamwezi',
	'nyn' => 'Nyankole',
	'nyo' => 'Nyoro',
	'nzi' => 'Nzima',
	'oc' => 'Occitan',
	'oj' => 'Ojibwa',
	'om' => 'Oromo',
	'or' => 'Oriya',
	'os' => 'Ossetic',
	'osa' => 'Osage',
	'ota' => 'Ottoman Turkish',
	'pa' => 'Punjabi',
	'pag' => 'Pangasinan',
	'pal' => 'Pahlavi',
	'pam' => 'Pampanga',
	'pap' => 'Papiamento',
	'pau' => 'Palauan',
	'pcd' => 'Picard',
	'pdc' => 'Pennsylvania German',
	'pdt' => 'Plautdietsch',
	'peo' => 'Old Persian',
	'pfl' => 'Palatine German',
	'phn' => 'Phoenician',
	'pi' => 'Pali',
	'pl' => 'Polish',
	'pms' => 'Piedmontese',
	'pnt' => 'Pontic',
	'pon' => 'Pohnpeian',
	'prg' => 'Prussian',
	'pro' => 'Old Provençal',
	'ps' => 'Pashto',
	'ps@alt=variant' => 'Pushto',
	'pt' => 'Portuguese',
	'pt_BR' => 'Brazilian Portuguese',
	'pt_PT' => 'European Portuguese',
	'qu' => 'Quechua',
	'quc' => 'Kʼicheʼ',
	'qug' => 'Chimborazo Highland Quichua',
	'raj' => 'Rajasthani',
	'rap' => 'Rapanui',
	'rar' => 'Rarotongan',
	'rgn' => 'Romagnol',
	'rif' => 'Riffian',
	'rm' => 'Romansh',
	'rn' => 'Rundi',
	'ro' => 'Romanian',
	'ro_MD' => 'Moldavian',
	'rof' => 'Rombo',
	'rom' => 'Romany',
	'root' => 'Root',
	'rtm' => 'Rotuman',
	'ru' => 'Russian',
	'rue' => 'Rusyn',
	'rug' => 'Roviana',
	'rup' => 'Aromanian',
	'rw' => 'Kinyarwanda',
	'rwk' => 'Rwa',
	'sa' => 'Sanskrit',
	'sad' => 'Sandawe',
	'sah' => 'Sakha',
	'sam' => 'Samaritan Aramaic',
	'saq' => 'Samburu',
	'sas' => 'Sasak',
	'sat' => 'Santali',
	'saz' => 'Saurashtra',
	'sba' => 'Ngambay',
	'sbp' => 'Sangu',
	'sc' => 'Sardinian',
	'scn' => 'Sicilian',
	'sco' => 'Scots',
	'sd' => 'Sindhi',
	'sdc' => 'Sassarese Sardinian',
	'se' => 'Northern Sami',
	'see' => 'Seneca',
	'seh' => 'Sena',
	'sei' => 'Seri',
	'sel' => 'Selkup',
	'ses' => 'Koyraboro Senni',
	'sg' => 'Sango',
	'sga' => 'Old Irish',
	'sgs' => 'Samogitian',
	'sh' => 'Serbo-Croatian',
	'shi' => 'Tachelhit',
	'shn' => 'Shan',
	'shu' => 'Chadian Arabic',
	'si' => 'Sinhala',
	'sid' => 'Sidamo',
	'sk' => 'Slovak',
	'sl' => 'Slovenian',
	'sli' => 'Lower Silesian',
	'sly' => 'Selayar',
	'sm' => 'Samoan',
	'sma' => 'Southern Sami',
	'smj' => 'Lule Sami',
	'smn' => 'Inari Sami',
	'sms' => 'Skolt Sami',
	'sn' => 'Shona',
	'snk' => 'Soninke',
	'so' => 'Somali',
	'sog' => 'Sogdien',
	'sq' => 'Albanian',
	'sr' => 'Serbian',
	'srn' => 'Sranan Tongo',
	'srr' => 'Serer',
	'ss' => 'Swati',
	'ssy' => 'Saho',
	'st' => 'Southern Sotho',
	'stq' => 'Saterland Frisian',
	'su' => 'Sundanese',
	'suk' => 'Sukuma',
	'sus' => 'Susu',
	'sux' => 'Sumerian',
	'sv' => 'Swedish',
	'sw' => 'Swahili',
	'swb' => 'Comorian',
	'swc' => 'Congo Swahili',
	'syc' => 'Classical Syriac',
	'syr' => 'Syriac',
	'szl' => 'Silesian',
	'ta' => 'Tamil',
	'tcy' => 'Tulu',
	'te' => 'Telugu',
	'tem' => 'Timne',
	'teo' => 'Teso',
	'ter' => 'Tereno',
	'tet' => 'Tetum',
	'tg' => 'Tajik',
	'th' => 'Thai',
	'ti' => 'Tigrinya',
	'tig' => 'Tigre',
	'tiv' => 'Tiv',
	'tk' => 'Turkmen',
	'tkl' => 'Tokelau',
	'tkr' => 'Tsakhur',
	'tl' => 'Tagalog',
	'tlh' => 'Klingon',
	'tli' => 'Tlingit',
	'tly' => 'Talysh',
	'tmh' => 'Tamashek',
	'tn' => 'Tswana',
	'to' => 'Tongan',
	'tog' => 'Nyasa Tonga',
	'tpi' => 'Tok Pisin',
	'tr' => 'Turkish',
	'tru' => 'Turoyo',
	'trv' => 'Taroko',
	'ts' => 'Tsonga',
	'tsd' => 'Tsakonian',
	'tsi' => 'Tsimshian',
	'tt' => 'Tatar',
	'ttt' => 'Muslim Tat',
	'tum' => 'Tumbuka',
	'tvl' => 'Tuvalu',
	'tw' => 'Twi',
	'twq' => 'Tasawaq',
	'ty' => 'Tahitian',
	'tyv' => 'Tuvinian',
	'tzm' => 'Central Atlas Tamazight',
	'udm' => 'Udmurt',
	'ug' => 'Uyghur',
	'ug@alt=variant' => 'Uighur',
	'uga' => 'Ugaritic',
	'uk' => 'Ukrainian',
	'umb' => 'Umbundu',
	'und' => 'Unknown Language',
	'ur' => 'Urdu',
	'uz' => 'Uzbek',
	'vai' => 'Vai',
	've' => 'Venda',
	'vec' => 'Venetian',
	'vep' => 'Veps',
	'vi' => 'Vietnamese',
	'vls' => 'West Flemish',
	'vmf' => 'Main-Franconian',
	'vo' => 'Volapük',
	'vot' => 'Votic',
	'vro' => 'Võro',
	'vun' => 'Vunjo',
	'wa' => 'Walloon',
	'wae' => 'Walser',
	'wal' => 'Walamo',
	'war' => 'Waray',
	'was' => 'Washo',
	'wo' => 'Wolof',
	'wuu' => 'Wu Chinese',
	'xal' => 'Kalmyk',
	'xh' => 'Xhosa',
	'xmf' => 'Mingrelian',
	'xog' => 'Soga',
	'yao' => 'Yao',
	'yap' => 'Yapese',
	'yav' => 'Yangben',
	'ybb' => 'Yemba',
	'yi' => 'Yiddish',
	'yo' => 'Yoruba',
	'yrl' => 'Nheengatu',
	'yue' => 'Cantonese',
	'za' => 'Zhuang',
	'zap' => 'Zapotec',
	'zbl' => 'Blissymbols',
	'zea' => 'Zeelandic',
	'zen' => 'Zenaga',
	'zgh' => 'Standard Moroccan Tamazight',
	'zh' => 'Chinese',
	'zh_Hans' => 'Simplified Chinese',
	'zh_Hant' => 'Traditional Chinese',
	'zu' => 'Zulu',
	'zun' => 'Zuni',
	'zxx' => 'No linguistic content',
	'zza' => 'Zaza',
};

is_deeply($locale->all_languages, $all_languages, 'All languages');

is($locale->script_name(), '', 'Script name from current locale');
is($locale->script_name('latn'), 'Latin', 'Script name from string');
is($locale->script_name($other_locale), '', 'Script name from other locale object');

my $all_scripts = {
	'Afak' => 'Afaka',
	'Aghb' => 'Caucasian Albanian',
	'Arab' => 'Arabic',
	'Arab@alt=variant' => 'Perso-Arabic',
	'Armi' => 'Imperial Aramaic',
	'Armn' => 'Armenian',
	'Avst' => 'Avestan',
	'Bali' => 'Balinese',
	'Bamu' => 'Bamum',
	'Bass' => 'Bassa Vah',
	'Batk' => 'Batak',
	'Beng' => 'Bengali',
	'Blis' => 'Blissymbols',
	'Bopo' => 'Bopomofo',
	'Brah' => 'Brahmi',
	'Brai' => 'Braille',
	'Bugi' => 'Buginese',
	'Buhd' => 'Buhid',
	'Cakm' => 'Chakma',
	'Cans' => 'Unified Canadian Aboriginal Syllabics',
	'Cans@alt=short' => 'UCAS',
	'Cari' => 'Carian',
	'Cham' => 'Cham',
	'Cher' => 'Cherokee',
	'Cirt' => 'Cirth',
	'Copt' => 'Coptic',
	'Cprt' => 'Cypriot',
	'Cyrl' => 'Cyrillic',
	'Cyrs' => 'Old Church Slavonic Cyrillic',
	'Deva' => 'Devanagari',
	'Dsrt' => 'Deseret',
	'Dupl' => 'Duployan shorthand',
	'Egyd' => 'Egyptian demotic',
	'Egyh' => 'Egyptian hieratic',
	'Egyp' => 'Egyptian hieroglyphs',
	'Elba' => 'Elbasan',
	'Ethi' => 'Ethiopic',
	'Geok' => 'Georgian Khutsuri',
	'Geor' => 'Georgian',
	'Glag' => 'Glagolitic',
	'Goth' => 'Gothic',
	'Gran' => 'Grantha',
	'Grek' => 'Greek',
	'Gujr' => 'Gujarati',
	'Guru' => 'Gurmukhi',
	'Hang' => 'Hangul',
	'Hani' => 'Han',
	'Hano' => 'Hanunoo',
	'Hans' => 'Simplified',
	'Hans@alt=stand-alone' => 'Simplified Han',
	'Hant' => 'Traditional',
	'Hant@alt=stand-alone' => 'Traditional Han',
	'Hebr' => 'Hebrew',
	'Hira' => 'Hiragana',
	'Hluw' => 'Anatolian Hieroglyphs',
	'Hmng' => 'Pahawh Hmong',
	'Hrkt' => 'Japanese syllabaries',
	'Hung' => 'Old Hungarian',
	'Inds' => 'Indus',
	'Ital' => 'Old Italic',
	'Java' => 'Javanese',
	'Jpan' => 'Japanese',
	'Jurc' => 'Jurchen',
	'Kali' => 'Kayah Li',
	'Kana' => 'Katakana',
	'Khar' => 'Kharoshthi',
	'Khmr' => 'Khmer',
	'Khoj' => 'Khojki',
	'Knda' => 'Kannada',
	'Kore' => 'Korean',
	'Kpel' => 'Kpelle',
	'Kthi' => 'Kaithi',
	'Lana' => 'Lanna',
	'Laoo' => 'Lao',
	'Latf' => 'Fraktur Latin',
	'Latg' => 'Gaelic Latin',
	'Latn' => 'Latin',
	'Lepc' => 'Lepcha',
	'Limb' => 'Limbu',
	'Lina' => 'Linear A',
	'Linb' => 'Linear B',
	'Lisu' => 'Fraser',
	'Loma' => 'Loma',
	'Lyci' => 'Lycian',
	'Lydi' => 'Lydian',
	'Mahj' => 'Mahajani',
	'Mand' => 'Mandaean',
	'Mani' => 'Manichaean',
	'Maya' => 'Mayan hieroglyphs',
	'Mend' => 'Mende',
	'Merc' => 'Meroitic Cursive',
	'Mero' => 'Meroitic',
	'Mlym' => 'Malayalam',
	'Modi' => 'Modi',
	'Mong' => 'Mongolian',
	'Moon' => 'Moon',
	'Mroo' => 'Mro',
	'Mtei' => 'Meitei Mayek',
	'Mymr' => 'Myanmar',
	'Narb' => 'Old North Arabian',
	'Nbat' => 'Nabataean',
	'Nkgb' => 'Naxi Geba',
	'Nkoo' => 'N’Ko',
	'Nshu' => 'Nüshu',
	'Ogam' => 'Ogham',
	'Olck' => 'Ol Chiki',
	'Orkh' => 'Orkhon',
	'Orya' => 'Oriya',
	'Osma' => 'Osmanya',
	'Palm' => 'Palmyrene',
	'Pauc' => 'Pau Cin Hau',
	'Perm' => 'Old Permic',
	'Phag' => 'Phags-pa',
	'Phli' => 'Inscriptional Pahlavi',
	'Phlp' => 'Psalter Pahlavi',
	'Phlv' => 'Book Pahlavi',
	'Phnx' => 'Phoenician',
	'Plrd' => 'Pollard Phonetic',
	'Prti' => 'Inscriptional Parthian',
	'Rjng' => 'Rejang',
	'Roro' => 'Rongorongo',
	'Runr' => 'Runic',
	'Samr' => 'Samaritan',
	'Sara' => 'Sarati',
	'Sarb' => 'Old South Arabian',
	'Saur' => 'Saurashtra',
	'Sgnw' => 'SignWriting',
	'Shaw' => 'Shavian',
	'Shrd' => 'Sharada',
	'Sidd' => 'Siddham',
	'Sind' => 'Khudawadi',
	'Sinh' => 'Sinhala',
	'Sora' => 'Sora Sompeng',
	'Sund' => 'Sundanese',
	'Sylo' => 'Syloti Nagri',
	'Syrc' => 'Syriac',
	'Syre' => 'Estrangelo Syriac',
	'Syrj' => 'Western Syriac',
	'Syrn' => 'Eastern Syriac',
	'Tagb' => 'Tagbanwa',
	'Takr' => 'Takri',
	'Tale' => 'Tai Le',
	'Talu' => 'New Tai Lue',
	'Taml' => 'Tamil',
	'Tang' => 'Tangut',
	'Tavt' => 'Tai Viet',
	'Telu' => 'Telugu',
	'Teng' => 'Tengwar',
	'Tfng' => 'Tifinagh',
	'Tglg' => 'Tagalog',
	'Thaa' => 'Thaana',
	'Thai' => 'Thai',
	'Tibt' => 'Tibetan',
	'Tirh' => 'Tirhuta',
	'Ugar' => 'Ugaritic',
	'Vaii' => 'Vai',
	'Visp' => 'Visible Speech',
	'Wara' => 'Varang Kshiti',
	'Wole' => 'Woleai',
	'Xpeo' => 'Old Persian',
	'Xsux' => 'Sumero-Akkadian Cuneiform',
	'Xsux@alt=short' => 'S-A Cuneiform',
	'Yiii' => 'Yi',
	'Zinh' => 'Inherited',
	'Zmth' => 'Mathematical Notation',
	'Zsym' => 'Symbols',
	'Zxxx' => 'Unwritten',
	'Zyyy' => 'Common',
	'Zzzz' => 'Unknown Script',
};

is_deeply($locale->all_scripts, $all_scripts, 'All scripts');

is($locale->territory_name(), 'United Kingdom', 'Territory name from current locale');
is($locale->territory_name('fr'), 'France', 'Territory name from string');
is($locale->territory_name($other_locale), 'New Zealand', 'Territory name from other locale object');

my $all_territories = {
	'001' => 'World',
	'002' => 'Africa',
	'003' => 'North America',
	'005' => 'South America',
	'009' => 'Oceania',
	'011' => 'Western Africa',
	'013' => 'Central America',
	'014' => 'Eastern Africa',
	'015' => 'Northern Africa',
	'017' => 'Middle Africa',
	'018' => 'Southern Africa',
	'019' => 'Americas',
	'021' => 'Northern America',
	'029' => 'Caribbean',
	'030' => 'Eastern Asia',
	'034' => 'Southern Asia',
	'035' => 'South-Eastern Asia',
	'039' => 'Southern Europe',
	'053' => 'Australasia',
	'054' => 'Melanesia',
	'057' => 'Micronesian Region',
	'061' => 'Polynesia',
	'142' => 'Asia',
	'143' => 'Central Asia',
	'145' => 'Western Asia',
	'150' => 'Europe',
	'151' => 'Eastern Europe',
	'154' => 'Northern Europe',
	'155' => 'Western Europe',
	'419' => 'Latin America',
	'AC' => 'Ascension Island',
	'AD' => 'Andorra',
	'AE' => 'United Arab Emirates',
	'AF' => 'Afghanistan',
	'AG' => 'Antigua and Barbuda',
	'AI' => 'Anguilla',
	'AL' => 'Albania',
	'AM' => 'Armenia',
	'AN' => 'Netherlands Antilles',
	'AO' => 'Angola',
	'AQ' => 'Antarctica',
	'AR' => 'Argentina',
	'AS' => 'American Samoa',
	'AT' => 'Austria',
	'AU' => 'Australia',
	'AW' => 'Aruba',
	'AX' => 'Åland Islands',
	'AZ' => 'Azerbaijan',
	'BA' => 'Bosnia and Herzegovina',
	'BA@alt=short' => 'Bosnia',
	'BB' => 'Barbados',
	'BD' => 'Bangladesh',
	'BE' => 'Belgium',
	'BF' => 'Burkina Faso',
	'BG' => 'Bulgaria',
	'BH' => 'Bahrain',
	'BI' => 'Burundi',
	'BJ' => 'Benin',
	'BL' => 'Saint Barthélemy',
	'BM' => 'Bermuda',
	'BN' => 'Brunei',
	'BO' => 'Bolivia',
	'BQ' => 'Caribbean Netherlands',
	'BR' => 'Brazil',
	'BS' => 'Bahamas',
	'BT' => 'Bhutan',
	'BV' => 'Bouvet Island',
	'BW' => 'Botswana',
	'BY' => 'Belarus',
	'BZ' => 'Belize',
	'CA' => 'Canada',
	'CC' => 'Cocos (Keeling) Islands',
	'CD' => 'Congo - Kinshasa',
	'CD@alt=variant' => 'Congo (DRC)',
	'CF' => 'Central African Republic',
	'CG' => 'Congo - Brazzaville',
	'CG@alt=variant' => 'Congo (Republic)',
	'CH' => 'Switzerland',
	'CI' => 'Côte d’Ivoire',
	'CI@alt=variant' => 'Ivory Coast',
	'CK' => 'Cook Islands',
	'CL' => 'Chile',
	'CM' => 'Cameroon',
	'CN' => 'China',
	'CO' => 'Colombia',
	'CP' => 'Clipperton Island',
	'CR' => 'Costa Rica',
	'CU' => 'Cuba',
	'CV' => 'Cape Verde',
	'CW' => 'Curaçao',
	'CX' => 'Christmas Island',
	'CY' => 'Cyprus',
	'CZ' => 'Czech Republic',
	'DE' => 'Germany',
	'DG' => 'Diego Garcia',
	'DJ' => 'Djibouti',
	'DK' => 'Denmark',
	'DM' => 'Dominica',
	'DO' => 'Dominican Republic',
	'DZ' => 'Algeria',
	'EA' => 'Ceuta and Melilla',
	'EC' => 'Ecuador',
	'EE' => 'Estonia',
	'EG' => 'Egypt',
	'EH' => 'Western Sahara',
	'ER' => 'Eritrea',
	'ES' => 'Spain',
	'ET' => 'Ethiopia',
	'EU' => 'European Union',
	'FI' => 'Finland',
	'FJ' => 'Fiji',
	'FK' => 'Falkland Islands',
	'FK@alt=variant' => 'Falkland Islands (Islas Malvinas)',
	'FM' => 'Micronesia',
	'FO' => 'Faroe Islands',
	'FR' => 'France',
	'GA' => 'Gabon',
	'GB' => 'United Kingdom',
	'GB@alt=short' => 'UK',
	'GD' => 'Grenada',
	'GE' => 'Georgia',
	'GF' => 'French Guiana',
	'GG' => 'Guernsey',
	'GH' => 'Ghana',
	'GI' => 'Gibraltar',
	'GL' => 'Greenland',
	'GM' => 'Gambia',
	'GN' => 'Guinea',
	'GP' => 'Guadeloupe',
	'GQ' => 'Equatorial Guinea',
	'GR' => 'Greece',
	'GS' => 'South Georgia & South Sandwich Islands',
	'GT' => 'Guatemala',
	'GU' => 'Guam',
	'GW' => 'Guinea-Bissau',
	'GY' => 'Guyana',
	'HK' => 'Hong Kong SAR China',
	'HK@alt=short' => 'Hong Kong',
	'HM' => 'Heard & McDonald Islands',
	'HN' => 'Honduras',
	'HR' => 'Croatia',
	'HT' => 'Haiti',
	'HU' => 'Hungary',
	'IC' => 'Canary Islands',
	'ID' => 'Indonesia',
	'IE' => 'Ireland',
	'IL' => 'Israel',
	'IM' => 'Isle of Man',
	'IN' => 'India',
	'IO' => 'British Indian Ocean Territory',
	'IQ' => 'Iraq',
	'IR' => 'Iran',
	'IS' => 'Iceland',
	'IT' => 'Italy',
	'JE' => 'Jersey',
	'JM' => 'Jamaica',
	'JO' => 'Jordan',
	'JP' => 'Japan',
	'KE' => 'Kenya',
	'KG' => 'Kyrgyzstan',
	'KH' => 'Cambodia',
	'KI' => 'Kiribati',
	'KM' => 'Comoros',
	'KN' => 'Saint Kitts and Nevis',
	'KP' => 'North Korea',
	'KR' => 'South Korea',
	'KW' => 'Kuwait',
	'KY' => 'Cayman Islands',
	'KZ' => 'Kazakhstan',
	'LA' => 'Laos',
	'LB' => 'Lebanon',
	'LC' => 'Saint Lucia',
	'LI' => 'Liechtenstein',
	'LK' => 'Sri Lanka',
	'LR' => 'Liberia',
	'LS' => 'Lesotho',
	'LT' => 'Lithuania',
	'LU' => 'Luxembourg',
	'LV' => 'Latvia',
	'LY' => 'Libya',
	'MA' => 'Morocco',
	'MC' => 'Monaco',
	'MD' => 'Moldova',
	'ME' => 'Montenegro',
	'MF' => 'Saint Martin',
	'MG' => 'Madagascar',
	'MH' => 'Marshall Islands',
	'MK' => 'Macedonia',
	'MK@alt=variant' => 'Macedonia (FYROM)',
	'ML' => 'Mali',
	'MM' => 'Myanmar (Burma)',
	'MM@alt=short' => 'Myanmar',
	'MN' => 'Mongolia',
	'MO' => 'Macau SAR China',
	'MO@alt=short' => 'Macau',
	'MP' => 'Northern Mariana Islands',
	'MQ' => 'Martinique',
	'MR' => 'Mauritania',
	'MS' => 'Montserrat',
	'MT' => 'Malta',
	'MU' => 'Mauritius',
	'MV' => 'Maldives',
	'MW' => 'Malawi',
	'MX' => 'Mexico',
	'MY' => 'Malaysia',
	'MZ' => 'Mozambique',
	'NA' => 'Namibia',
	'NC' => 'New Caledonia',
	'NE' => 'Niger',
	'NF' => 'Norfolk Island',
	'NG' => 'Nigeria',
	'NI' => 'Nicaragua',
	'NL' => 'Netherlands',
	'NO' => 'Norway',
	'NP' => 'Nepal',
	'NR' => 'Nauru',
	'NU' => 'Niue',
	'NZ' => 'New Zealand',
	'OM' => 'Oman',
	'PA' => 'Panama',
	'PE' => 'Peru',
	'PF' => 'French Polynesia',
	'PG' => 'Papua New Guinea',
	'PH' => 'Philippines',
	'PK' => 'Pakistan',
	'PL' => 'Poland',
	'PM' => 'Saint Pierre and Miquelon',
	'PN' => 'Pitcairn Islands',
	'PR' => 'Puerto Rico',
	'PS' => 'Palestinian Territories',
	'PS@alt=short' => 'Palestine',
	'PT' => 'Portugal',
	'PW' => 'Palau',
	'PY' => 'Paraguay',
	'QA' => 'Qatar',
	'QO' => 'Outlying Oceania',
	'RE' => 'Réunion',
	'RO' => 'Romania',
	'RS' => 'Serbia',
	'RU' => 'Russia',
	'RW' => 'Rwanda',
	'SA' => 'Saudi Arabia',
	'SB' => 'Solomon Islands',
	'SC' => 'Seychelles',
	'SD' => 'Sudan',
	'SE' => 'Sweden',
	'SG' => 'Singapore',
	'SH' => 'Saint Helena',
	'SI' => 'Slovenia',
	'SJ' => 'Svalbard and Jan Mayen',
	'SK' => 'Slovakia',
	'SL' => 'Sierra Leone',
	'SM' => 'San Marino',
	'SN' => 'Senegal',
	'SO' => 'Somalia',
	'SR' => 'Suriname',
	'SS' => 'South Sudan',
	'ST' => 'São Tomé and Príncipe',
	'SV' => 'El Salvador',
	'SX' => 'Sint Maarten',
	'SY' => 'Syria',
	'SZ' => 'Swaziland',
	'TA' => 'Tristan da Cunha',
	'TC' => 'Turks and Caicos Islands',
	'TD' => 'Chad',
	'TF' => 'French Southern Territories',
	'TG' => 'Togo',
	'TH' => 'Thailand',
	'TJ' => 'Tajikistan',
	'TK' => 'Tokelau',
	'TL' => 'Timor-Leste',
	'TL@alt=variant' => 'East Timor',
	'TM' => 'Turkmenistan',
	'TN' => 'Tunisia',
	'TO' => 'Tonga',
	'TR' => 'Turkey',
	'TT' => 'Trinidad and Tobago',
	'TV' => 'Tuvalu',
	'TW' => 'Taiwan',
	'TZ' => 'Tanzania',
	'UA' => 'Ukraine',
	'UG' => 'Uganda',
	'UM' => 'U.S. Outlying Islands',
	'US' => 'United States',
	'US@alt=short' => 'US',
	'UY' => 'Uruguay',
	'UZ' => 'Uzbekistan',
	'VA' => 'Vatican City',
	'VC' => 'St. Vincent & Grenadines',
	'VE' => 'Venezuela',
	'VG' => 'British Virgin Islands',
	'VI' => 'U.S. Virgin Islands',
	'VN' => 'Vietnam',
	'VU' => 'Vanuatu',
	'WF' => 'Wallis and Futuna',
	'WS' => 'Samoa',
	'XK' => 'Kosovo',
	'YE' => 'Yemen',
	'YT' => 'Mayotte',
	'ZA' => 'South Africa',
	'ZM' => 'Zambia',
	'ZW' => 'Zimbabwe',
	'ZZ' => 'Unknown Region',
};

is_deeply($locale->all_territories(), $all_territories, 'All Territories');

is($locale->variant_name(), '', 'Variant name from current locale');
is($locale->variant_name('BOHORIC'), 'Bohorič alphabet', 'Variant name from string');
is($locale->variant_name($other_locale), '', 'Variant name from other locale object');

is($locale->key_name('colCaseLevel'), 'Case-Sensitive Sorting', 'Key name from string');

is($locale->type_name(colCaseFirst => 'lower'), 'Sort Lowercase First', 'Type name from string');

is($locale->measurement_system_name('metric'), 'Metric', 'Measurement system name English Metric');
is($locale->measurement_system_name('us'), 'US', 'Measurement system name English US');
is($locale->measurement_system_name('uk'), 'UK', 'Measurement system name English UK');

is($locale->transform_name('Numeric'), 'Numeric', 'Transform name from string');