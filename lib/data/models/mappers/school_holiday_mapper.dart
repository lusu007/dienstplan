import '../../../domain/entities/school_holiday.dart' as domain;
import '../school_holiday.dart';

/// Maps between data models and domain entities for school holidays
class SchoolHolidayMapper {
  const SchoolHolidayMapper();

  /// Convert from data model to domain entity
  domain.SchoolHoliday toDomain(SchoolHoliday model) {
    return domain.SchoolHoliday(
      id: model.id,
      name: model.name,
      startDate: model.startDate,
      endDate: model.endDate,
      stateCode: model.stateCode,
      stateName: model.stateName,
      description: model.description,
      type: _mapHolidayType(model.type),
    );
  }

  /// Convert from domain entity to data model
  SchoolHoliday toModel(domain.SchoolHoliday entity) {
    return SchoolHoliday(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      stateCode: entity.stateCode,
      stateName: entity.stateName,
      year: entity.startDate.year,
      description: entity.description,
      type: _mapHolidayTypeToString(entity.type),
    );
  }

  /// Convert a list of data models to domain entities
  List<domain.SchoolHoliday> toDomainList(List<SchoolHoliday> models) {
    return models.map(toDomain).toList();
  }

  /// Convert a list of domain entities to data models
  List<SchoolHoliday> toModelList(List<domain.SchoolHoliday> entities) {
    return entities.map(toModel).toList();
  }

  /// Map string type to enum
  domain.HolidayType? _mapHolidayType(String? type) {
    if (type == null) return null;

    switch (type.toLowerCase()) {
      case 'regular':
      case 'ferien':
        return domain.HolidayType.regular;
      case 'public':
      case 'feiertag':
        return domain.HolidayType.publicHoliday;
      case 'movable':
      case 'beweglich':
        return domain.HolidayType.movableHoliday;
      default:
        return domain.HolidayType.other;
    }
  }

  /// Map enum type to string
  String? _mapHolidayTypeToString(domain.HolidayType? type) {
    if (type == null) return null;

    switch (type) {
      case domain.HolidayType.regular:
        return 'regular';
      case domain.HolidayType.publicHoliday:
        return 'public';
      case domain.HolidayType.movableHoliday:
        return 'movable';
      case domain.HolidayType.other:
        return 'other';
    }
  }
}
