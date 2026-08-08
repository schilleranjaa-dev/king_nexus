import '../models/event_group_model.dart';
import '../services/event_group_service.dart';

class EventGroupRepository {
  final EventGroupService _groupService;

  EventGroupRepository({
    EventGroupService? groupService,
  }) : _groupService =
            groupService ?? EventGroupService();

  Future<void> saveGroup({
    required String eventId,
    required EventGroupModel group,
  }) {
    return _groupService.saveGroup(
      eventId: eventId,
      group: group,
    );
  }

  Future<void> saveGroups({
    required String eventId,
    required List<EventGroupModel> groups,
  }) {
    return _groupService.saveGroups(
      eventId: eventId,
      groups: groups,
    );
  }

  Future<EventGroupModel?> getGroup({
    required String eventId,
    required String groupId,
  }) {
    return _groupService.getGroup(
      eventId: eventId,
      groupId: groupId,
    );
  }

  Stream<EventGroupModel?> watchGroup({
    required String eventId,
    required String groupId,
  }) {
    return _groupService.watchGroup(
      eventId: eventId,
      groupId: groupId,
    );
  }

  Stream<List<EventGroupModel>> watchGroups(
    String eventId,
  ) {
    return _groupService.watchGroups(
      eventId,
    );
  }

  Future<void> deleteGroup({
    required String eventId,
    required String groupId,
  }) {
    return _groupService.deleteGroup(
      eventId: eventId,
      groupId: groupId,
    );
  }

  Future<void> setGroupDateTime({
    required String eventId,
    required String groupId,
    required DateTime dateTime,
  }) {
    return _groupService.setGroupDateTime(
      eventId: eventId,
      groupId: groupId,
      dateTime: dateTime,
    );
  }

  Future<void> setInheritsTimeFrom({
    required String eventId,
    required String groupId,
    String? inheritsTimeFrom,
  }) {
    return _groupService.setInheritsTimeFrom(
      eventId: eventId,
      groupId: groupId,
      inheritsTimeFrom: inheritsTimeFrom,
    );
  }
}