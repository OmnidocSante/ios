import 'package:flutter_test/flutter_test.dart';
import 'package:regulation_assiste/models/home_model.dart';

void main() {
  test('Création d\'un MissionModel à partir de JSON', () {
    final missionJson = {
      "id": 134,
      "patient_id": 7,
      "etat_mission": "urgente",
      "statut": "en cours",
      "date_mission": "2025-05-14T09:43",
      "heure_depart": "2025-05-14T10:44:12",
      "heure_arrivee": null,
      "heure_affectation": null,
      "heure_redepart": null,
      "heure_fin": null,
      "urgence": 1,
      "créé_le": "2025-05-14T09:44:12.000Z",
      "type_mission": "ambulance",
      "cause": "Alerte allergique grave (choc anaphylactique)",
      "bon_de_commande": "QDSD",
      "demande_materiel": "QSD",
      "ambulancier_id": 21,
      "adresse": "ZAQSDQ",
      "adresse_destination": null,
      "doctor_id": null,
      "nurse_id": null,
      "prix": "12.00",
      "paiement": "cache",
      "paye": 0,
      "ville": "Nador",
      "temps_depart": null,
      "temps_arrivee": null,
      "temps_total": "00:00:00.000000",
      "temps_redepart": null,
      "temps_fin": null
    };

    final mission = MissionModel.fromJson(missionJson);

    // Vérification des valeurs
    expect(mission.id, equals(134));
    expect(mission.patientId, equals(7));
    expect(mission.etatMission, equals("urgente"));
    expect(mission.statut, equals("en cours"));
    expect(mission.dateMission, equals("2025-05-14T09:43"));
    expect(mission.heureDepart, equals("2025-05-14T10:44:12"));
    expect(mission.ambulancierId, equals(21));
    expect(mission.ville, equals("Nador"));
    expect(mission.prix, equals("12.00"));
    expect(
        mission.cause, equals("Alerte allergique grave (choc anaphylactique)"));

    // Conversion en JSON
    final jsonResult = mission.toJson();
    expect(jsonResult['id'], equals(134));
    expect(jsonResult['patient_id'], equals(7));
    expect(jsonResult['ambulancier_id'], equals(21));
  });

  test('Création d\'un HomeModel avec MissionModel', () {
    final missionModel = MissionModel(
        id: 134,
        patientId: 7,
        etatMission: "urgente",
        statut: "en cours",
        typeMission: "ambulance",
        ambulancierId: 21,
        ville: "Nador",
        prix: "12.00");

    final homeModel = HomeModel(
        userName: "Test User",
        userId: "21",
        userAvatar: "",
        userEmail: "test@example.com",
        userPhone: "123456789",
        userGender: "M",
        userBirthDate: "1990-01-01",
        userRole: "ambulancier",
        userStatus: "actif",
        nextMission: missionModel,
        ambulanceId: 1);

    expect(homeModel.nextMission?.id, equals(134));
    expect(homeModel.nextMission?.ambulancierId, equals(21));
    expect(homeModel.userId, equals("21"));
    expect(homeModel.userRole, equals("ambulancier"));
  });
}
