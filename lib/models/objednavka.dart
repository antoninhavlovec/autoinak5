import 'package:cloud_firestore/cloud_firestore.dart';

class Objednavka {
  final Timestamp createdAt;
  final dynamic inoSrvszakBarvyVozuNazevSubjektu; // nullable
  final String inoSrvszakHlavickaExp685235;
  final num inoSrvszakHlavickaCenaCelkem;
  final String inoSrvszakHlavickaCisloCp;
  final String inoSrvszakHlavickaEmail;
  final String inoSrvszakHlavickaHodnoceni;
  final String inoSrvszakHlavickaKomise;
  final String inoSrvszakHlavickaMisto;
  final String inoSrvszakHlavickaOrganizaceDic;
  final String inoSrvszakHlavickaOrganizaceIco;
  final dynamic inoSrvszakHlavickaPneuVydanoDne; // nullable
  final String inoSrvszakHlavickaPneuVyrobce;
  final dynamic inoSrvszakHlavickaPojistka2; // nullable
  final String inoSrvszakHlavickaPsc;
  final String inoSrvszakHlavickaReferenceSubjektu;
  final String inoSrvszakHlavickaStav;
  final dynamic inoSrvszakHlavickaTelefon; // nullable
  final String inoSrvszakHlavickaTelefonMobil;
  final String inoSrvszakHlavickaUlice;
  final String inoSrvszakHlavickaVin1;
  final String inoSrvszakHlavickaVyrCisloMotoru;
  final String inoTypVozidlaInoNazevNad;
  final String inoZnackamodelExp10306329;
  final String inoZnackamodelExp48481880;
  final String inoZnackamodelMotor;
  final num inoZnackamodelVykonHp;
  final String objednavkaId;
  final dynamic organizaceCisloCp; // nullable
  final dynamic organizaceDic; // nullable
  final dynamic organizaceEmail; // nullable
  final dynamic organizaceIco; // nullable
  final dynamic organizaceMisto; // nullable
  final dynamic organizaceNazevSubjektu; // nullable
  final dynamic organizaceNazevSubjektu0001; // nullable
  final dynamic organizacePsc; // nullable
  final dynamic organizaceTelefon; // nullable
  final dynamic organizaceTelefonMobil; // nullable
  final dynamic organizaceUliceDs; // nullable
  final num subjektyCisloSubjektu;
  final String subjektyDatumVzniku0001;
  final String subjektyNazevSubjektu;
  final dynamic subjektyReferenceSubjektu; // nullable
  final String udaInoZavaznaObjednavkaDatumFa;
  final String udaInoZavaznaObjednavkaDatumSepsani;
  final dynamic udaInoZavaznaObjednavkaLeasingSmlouvaCislo; // nullable
  final dynamic udaInoZavaznaObjednavkaLokacePoznamka; // nullable
  final String udaInoZavaznaObjednavkaLokaceVozu;
  final dynamic udaInoZavaznaObjednavkaSelfRegistraceDatum; // nullable
  final String udaInoZavaznaObjednavkaZavaznaObjednavka;
  final String udaInoZavaznaObjednavkaZfinancovani;
  final String udaInoZnackamodelPrevodovka;
  final String udaInoZnackamodelRok;
  final dynamic zamestnanciPrijmeni; // nullable

  Objednavka({
    required this.createdAt,
    required this.inoSrvszakBarvyVozuNazevSubjektu,
    required this.inoSrvszakHlavickaExp685235,
    required this.inoSrvszakHlavickaCenaCelkem,
    required this.inoSrvszakHlavickaCisloCp,
    required this.inoSrvszakHlavickaEmail,
    required this.inoSrvszakHlavickaHodnoceni,
    required this.inoSrvszakHlavickaKomise,
    required this.inoSrvszakHlavickaMisto,
    required this.inoSrvszakHlavickaOrganizaceDic,
    required this.inoSrvszakHlavickaOrganizaceIco,
    required this.inoSrvszakHlavickaPneuVydanoDne,
    required this.inoSrvszakHlavickaPneuVyrobce,
    required this.inoSrvszakHlavickaPojistka2,
    required this.inoSrvszakHlavickaPsc,
    required this.inoSrvszakHlavickaReferenceSubjektu,
    required this.inoSrvszakHlavickaStav,
    required this.inoSrvszakHlavickaTelefon,
    required this.inoSrvszakHlavickaTelefonMobil,
    required this.inoSrvszakHlavickaUlice,
    required this.inoSrvszakHlavickaVin1,
    required this.inoSrvszakHlavickaVyrCisloMotoru,
    required this.inoTypVozidlaInoNazevNad,
    required this.inoZnackamodelExp10306329,
    required this.inoZnackamodelExp48481880,
    required this.inoZnackamodelMotor,
    required this.inoZnackamodelVykonHp,
    required this.objednavkaId,
    required this.organizaceCisloCp,
    required this.organizaceDic,
    required this.organizaceEmail,
    required this.organizaceIco,
    required this.organizaceMisto,
    required this.organizaceNazevSubjektu,
    required this.organizaceNazevSubjektu0001,
    required this.organizacePsc,
    required this.organizaceTelefon,
    required this.organizaceTelefonMobil,
    required this.organizaceUliceDs,
    required this.subjektyCisloSubjektu,
    required this.subjektyDatumVzniku0001,
    required this.subjektyNazevSubjektu,
    required this.subjektyReferenceSubjektu,
    required this.udaInoZavaznaObjednavkaDatumFa,
    required this.udaInoZavaznaObjednavkaDatumSepsani,
    required this.udaInoZavaznaObjednavkaLeasingSmlouvaCislo,
    required this.udaInoZavaznaObjednavkaLokacePoznamka,
    required this.udaInoZavaznaObjednavkaLokaceVozu,
    required this.udaInoZavaznaObjednavkaSelfRegistraceDatum,
    required this.udaInoZavaznaObjednavkaZavaznaObjednavka,
    required this.udaInoZavaznaObjednavkaZfinancovani,
    required this.udaInoZnackamodelPrevodovka,
    required this.udaInoZnackamodelRok,
    required this.zamestnanciPrijmeni,
  });

  factory Objednavka.fromFirestore(Map<String, dynamic> data) {
    return Objednavka(
        createdAt: data['created_at'] ?? Timestamp.now(),
    inoSrvszakBarvyVozuNazevSubjektu: data['ino_srvszak_barvy_vozu_nazev_subjektu'],
    inoSrvszakHlavickaExp685235: data['ino_srvszak_hlavicka_Exp685235'] ?? '',
    inoSrvszakHlavickaCenaCelkem: data['ino_srvszak_hlavicka_cena_celkem'] ?? 0,
    inoSrvszakHlavickaCisloCp: data['ino_srvszak_hlavicka_cislo_cp'] ?? '',
    inoSrvszakHlavickaEmail: data['ino_srvszak_hlavicka_e_mail'] ??'',
    inoSrvszakHlavickaHodnoceni: data['ino_srvszak_hlavicka_hodnoceni'] ?? '',
    inoSrvszakHlavickaKomise: data['ino_srvszak_hlavicka_komise'] ?? '',
    inoSrvszakHlavickaMisto: data['ino_srvszak_hlavicka_misto'] ?? '',
    inoSrvszakHlavickaOrganizaceDic:
    data['ino_srvszak_hlavicka_organizace_dic'] ?? '',
    inoSrvszakHlavickaOrganizaceIco:
    data['ino_srvszak_hlavicka_organizace_ico'] ?? '',
    inoSrvszakHlavickaPneuVydanoDne:
    data['ino_srvszak_hlavicka_pneu_vydano_dne'],
    inoSrvszakHlavickaPneuVyrobce:
    data['ino_srvszak_hlavicka_pneu_vyrobce'] ?? '',
    inoSrvszakHlavickaPojistka2: data['ino_srvszak_hlavicka_pojistka2'],
    inoSrvszakHlavickaPsc: data['ino_srvszak_hlavicka_psc'] ?? '',
    inoSrvszakHlavickaReferenceSubjektu:
    data['ino_srvszak_hlavicka_reference_subjektu'] ?? '',
    inoSrvszakHlavickaStav: data['ino_srvszak_hlavicka_stav'] ?? '',
    inoSrvszakHlavickaTelefon: data['ino_srvszak_hlavicka_telefon'],
    inoSrvszakHlavickaTelefonMobil:
    data['ino_srvszak_hlavicka_telefon_mobil'] ?? '',
    inoSrvszakHlavickaUlice: data['ino_srvszak_hlavicka_ulice'] ?? '',
    inoSrvszakHlavickaVin1: data['ino_srvszak_hlavicka_vin1'] ?? '',
    inoSrvszakHlavickaVyrCisloMotoru:
    data['ino_srvszak_hlavicka_vyr_cislo_motoru'] ?? '',
    inoTypVozidlaInoNazevNad: data['ino_typ_vozidla_ino_nazev_nad'] ?? '',
    inoZnackamodelExp10306329: data['ino_znackamodel_Exp10306329'] ?? '',
    inoZnackamodelExp48481880: data['ino_znackamodel_Exp48481880'] ?? '',
    inoZnackamodelMotor: data['ino_znackamodel_motor'] ?? '',
    inoZnackamodelVykonHp: data['ino_znackamodel_vykon_hp'] ?? 0,
    objednavkaId: data['objednavkaId'] ?? '',
    organizaceCisloCp: data['organizace_cislo_cp'],
    organizaceDic: data['organizace_dic'],
    organizaceEmail: data['organizace_e_mail'],
    organizaceIco: data['organizace_ico'],
    organizaceMisto: data['organizace_misto'],
    organizaceNazevSubjektu: data['organizace_nazev_subjektu'],
    organizaceNazevSubjektu0001: data['organizace_nazev_subjektu_0001'],
    organizacePsc: data['organizace_psc'],
    organizaceTelefon: data['organizace_telefon'],
    organizaceTelefonMobil: data['organizace_telefon_mobil'],
    organizaceUliceDs: data['organizace_ulice_ds'],
    subjektyCisloSubjektu: data['subjekty_cislo_subjektu'] ?? 0,
    subjektyDatumVzniku0001: data['subjekty_datum_vzniku_0001'] ?? '',
    subjektyNazevSubjektu: data['subjekty_nazev_subjektu'] ?? '',
    subjektyReferenceSubjektu: data['subjekty_reference_subjektu'],
      udaInoZavaznaObjednavkaDatumFa:
      data['uda_ino_zavazna_objednavka_datum_fa'] ?? '',
      udaInoZavaznaObjednavkaDatumSepsani:
      data['uda_ino_zavazna_objednavka_datum_sepsani'] ?? '',
      udaInoZavaznaObjednavkaLeasingSmlouvaCislo:
      data['uda_ino_zavazna_objednavka_leasing_smlouva_cislo'],
      udaInoZavaznaObjednavkaLokacePoznamka:
      data['uda_ino_zavazna_objednavka_lokace_poznamka'],
      udaInoZavaznaObjednavkaLokaceVozu:
      data['uda_ino_zavazna_objednavka_lokace_vozu'] ?? '',
      udaInoZavaznaObjednavkaSelfRegistraceDatum:
      data['uda_ino_zavazna_objednavka_self_registrace_datum'],
      udaInoZavaznaObjednavkaZavaznaObjednavka:
      data['uda_ino_zavazna_objednavka_zavazna_objednavka'] ?? '',
      udaInoZavaznaObjednavkaZfinancovani:
      data['uda_ino_zavazna_objednavka_zfinancovani'] ?? '',
      udaInoZnackamodelPrevodovka:
      data['uda_ino_znackamodel_prevodovka'] ?? '',
      udaInoZnackamodelRok: data['uda_ino_znackamodel_rok'] ?? '',
      zamestnanciPrijmeni: data['zamestnanci_prijmeni'],
    );
  }
}