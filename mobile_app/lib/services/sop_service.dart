import '../models/incident_model.dart';

class SOPStep {
  final String description;
  final bool isRequired;

  SOPStep({required this.description, this.isRequired = true});
}

class SOPService {
  static List<SOPStep> getStepsForType(IncidentType type) {
    switch (type) {
      case IncidentType.sos:
        return [
          SOPStep(description: 'Verify immediate safety and surroundings'),
          SOPStep(description: 'Activate live location tracking'),
          SOPStep(description: 'Prepare to receive incoming tactical call'),
          SOPStep(description: 'Identify nearest safe exit or extraction point'),
        ];
      case IncidentType.fire:
        return [
          SOPStep(description: 'Evacuate all personnel from the immediate area'),
          SOPStep(description: 'Sound the local alarm manually if not active'),
          SOPStep(description: 'Attempt to contain using extinguisher if safe'),
          SOPStep(description: 'Contact local Fire Department via backup channel'),
        ];
      case IncidentType.medical:
        return [
          SOPStep(description: 'Check breathing and consciousness'),
          SOPStep(description: 'Administer basic first aid (BLS)'),
          SOPStep(description: 'Wait for medical response team at entry point'),
          SOPStep(description: 'Gather patient ID and medical history if possible'),
        ];
      case IncidentType.security:
        return [
          SOPStep(description: 'Secure all perimeter access points'),
          SOPStep(description: 'Monitor CCTV feeds for unauthorized movement'),
          SOPStep(description: 'Maintain radio silence unless reporting contact'),
          SOPStep(description: 'Identify and describe suspect physical traits'),
        ];
      default:
        return [
          SOPStep(description: 'Acknowledge incident receipt'),
          SOPStep(description: 'Monitor situation and record details'),
          SOPStep(description: 'Report changes to command center'),
        ];
    }
  }
}
