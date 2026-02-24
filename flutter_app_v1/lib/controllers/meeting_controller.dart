import 'package:get/get.dart';
import '../data/models/meeting_model.dart';
import '../data/providers/meeting_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingController extends GetxController {
  final MeetingProvider _provider = MeetingProvider();

  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadMeetings() async {
    try {
      isLoading.value = true;
      final response = await _provider.getMeetings();
      final data = response.data;
      final listData = data['data'] ?? data;

      if (listData is List) {
        meetings.value = listData.map((e) => MeetingModel.fromJson(e)).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> scheduleMeeting(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _provider.scheduleMeeting(data);
      await loadMeetings();
      return true;
    } catch (e) {
      error.value = 'Failed to schedule meeting';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMeeting(Map<String, dynamic> data) async {
    try {
      await _provider.updateMeeting(data);
      await loadMeetings();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMeeting(String meetingId) async {
    try {
      await _provider.deleteMeeting(meetingId);
      meetings.removeWhere((m) => m.id == meetingId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> joinMeeting(String meetingId) async {
    try {
      final response = await _provider.generateMeetingToken(meetingId);
      final data = response.data;
      final tokenData = data['data'] ?? data;
      final token = tokenData['token'] ?? tokenData;
      final meeting = meetings.firstWhereOrNull((m) => m.id == meetingId);
      final roomName = meeting?.roomName ?? meetingId;

      // Launch Jitsi meet in browser
      final url = 'https://8x8.vc/$roomName?jwt=$token';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      error.value = 'Failed to join meeting';
    }
  }
}
