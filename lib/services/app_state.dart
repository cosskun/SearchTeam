import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/match_ad.dart';
import '../models/review.dart';
import '../models/application.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../data/seed_data.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();

  // Data Collections
  final List<AppUser> _users = [];
  final List<MatchAd> _matches = [];
  final List<Application> _applications = [];
  final List<Review> _reviews = [];
  final List<ChatSession> _chatSessions = [];
  final List<ChatMessage> _chatMessages = [];

  // Active Session
  AppUser? _currentUser;

  // Getters
  List<AppUser> get users => List.unmodifiable(_users);
  List<MatchAd> get matches => List.unmodifiable(_matches);
  List<Application> get applications => List.unmodifiable(_applications);
  List<Review> get reviews => List.unmodifiable(_reviews);
  List<ChatSession> get chatSessions => List.unmodifiable(_chatSessions);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  AppUser? get currentUser => _currentUser;

  AppState() {
    _seedData();
  }

  // Seed initial mock data from SeedData helper
  void _seedData() {
    _users.addAll(SeedData.getInitialUsers());
    _currentUser = _users.isNotEmpty ? _users.first : null;
    _reviews.addAll(SeedData.getInitialReviews());
    _matches.addAll(SeedData.getInitialMatches());
    _applications.addAll(SeedData.getInitialApplications());

    final chatData = SeedData.getInitialChatData();
    _chatSessions.addAll(chatData['sessions'] as List<ChatSession>);
    _chatMessages.addAll(chatData['messages'] as List<ChatMessage>);
  }

  // Auth Operations
  bool login(String email, String password) {
    // Basic mock login: find existing user by email
    final index = _users.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase().trim());
    if (index != -1) {
      _currentUser = _users[index];
      notifyListeners();
      return true;
    }
    // If not found, let's create a new one automatically for easy demoing
    final name = email.split('@')[0];
    final newUser = AppUser(
      id: _uuid.v4(),
      name: name[0].toUpperCase() + name.substring(1),
      email: email.trim(),
      phoneNumber: '0555 999 8877',
      bio: 'Yeni katıldım. Futbolu çok severim!',
      rating: 5.0,
      totalReviews: 0,
      totalMatchesPlayed: 0,
      totalMatchesHosted: 0,
      height: 180,
      weight: 75,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  void register(String name, String email, String phoneNumber, String bio) {
    final newUser = AppUser(
      id: _uuid.v4(),
      name: name,
      email: email.trim(),
      phoneNumber: phoneNumber,
      bio: bio,
      rating: 5.0,
      totalReviews: 0,
      totalMatchesPlayed: 0,
      totalMatchesHosted: 0,
      height: 180,
      weight: 75,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String bio,
    required List<PositionType> preferredPositions,
    required bool isContactInfoPublic,
    required bool shareContactOnApproval,
    double? height,
    double? weight,
    required String avatarUrl,
  }) {
    if (_currentUser == null) return;
    
    // Update active user in the lists
    final index = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        name: name,
        phoneNumber: phone,
        bio: bio,
        preferredPositions: preferredPositions,
        isContactInfoPublic: isContactInfoPublic,
        shareContactOnApproval: shareContactOnApproval,
        height: height,
        weight: weight,
        avatarUrl: avatarUrl,
      );
      _currentUser = _users[index];
      notifyListeners();
    }
  }

  void shareContactInfoForApplication(String applicationId) {
    final index = _applications.indexWhere((app) => app.id == applicationId);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(isContactShared: true);
      notifyListeners();
    }
  }

  String startOrGetChatSession(String recipientUserId) {
    if (_currentUser == null) return '';
    final myId = _currentUser!.id;
    
    final existingIndex = _chatSessions.indexWhere((session) =>
        session.memberIds.contains(myId) && session.memberIds.contains(recipientUserId));
    
    if (existingIndex != -1) {
      return _chatSessions[existingIndex].id;
    }
    
    final newSessionId = 'session_${_uuid.v4()}';
    final newSession = ChatSession(
      id: newSessionId,
      memberIds: [myId, recipientUserId],
      lastMessageText: 'Sohbet başlatıldı.',
      lastMessageTime: DateTime.now(),
      unreadCountByUserId: {
        myId: 0,
        recipientUserId: 0,
      },
    );
    
    _chatSessions.add(newSession);
    notifyListeners();
    return newSessionId;
  }

  void sendMessage(String sessionId, String text, {String? imageUrl}) {
    if (_currentUser == null) return;
    final myId = _currentUser!.id;
    
    final sessionIndex = _chatSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;
    final session = _chatSessions[sessionIndex];
    
    final newMessage = ChatMessage(
      id: 'msg_${_uuid.v4()}',
      sessionId: sessionId,
      senderId: myId,
      senderName: _currentUser!.name,
      text: text,
      dateTime: DateTime.now(),
      isRead: false,
      imageUrl: imageUrl,
    );
    
    _chatMessages.add(newMessage);
    
    final updatedUnread = Map<String, int>.from(session.unreadCountByUserId);
    for (final memberId in session.memberIds) {
      if (memberId != myId) {
        updatedUnread[memberId] = (updatedUnread[memberId] ?? 0) + 1;
      }
    }
    
    _chatSessions[sessionIndex] = session.copyWith(
      lastMessageText: imageUrl != null ? '📷 Fotoğraf' : text,
      lastMessageTime: DateTime.now(),
      unreadCountByUserId: updatedUnread,
    );
    
    notifyListeners();
  }

  void markChatAsRead(String sessionId) {
    if (_currentUser == null) return;
    final myId = _currentUser!.id;
    
    final sessionIndex = _chatSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;
    final session = _chatSessions[sessionIndex];
    
    final updatedUnread = Map<String, int>.from(session.unreadCountByUserId);
    updatedUnread[myId] = 0;
    
    _chatSessions[sessionIndex] = session.copyWith(
      unreadCountByUserId: updatedUnread,
    );
    
    for (int i = 0; i < _chatMessages.length; i++) {
      if (_chatMessages[i].sessionId == sessionId && _chatMessages[i].senderId != myId) {
        _chatMessages[i] = _chatMessages[i].copyWith(isRead: true);
      }
    }
    
    notifyListeners();
  }

  // Match Ad Operations
  void createMatchAd({
    required String title,
    required String description,
    required String locationName,
    required String district,
    required DateTime dateTime,
    required double price,
    required PositionType requiredPosition,
    required int spotsNeeded,
    double? latitude,
    double? longitude,
  }) {
    if (_currentUser == null) return;

    final newAd = MatchAd(
      id: _uuid.v4(),
      hostId: _currentUser!.id,
      hostName: _currentUser!.name,
      hostRating: _currentUser!.rating,
      title: title,
      description: description,
      locationName: locationName,
      district: district,
      latitude: latitude,
      longitude: longitude,
      dateTime: dateTime,
      price: price,
      requiredPosition: requiredPosition,
      spotsNeeded: spotsNeeded,
    );

    _matches.insert(0, newAd); // Prepend so it appears first in feed

    // Increment host statistics
    final userIndex = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(
        totalMatchesHosted: _users[userIndex].totalMatchesHosted + 1,
      );
      _currentUser = _users[userIndex];
    }

    notifyListeners();
  }

  void cancelMatchAd(String matchId) {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      _matches[index] = _matches[index].copyWith(status: MatchStatus.cancelled);
      notifyListeners();
    }
  }

  void updateTacticalRoster(String matchId, String tacticalPositionKey, String userId) {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final updatedRoster = Map<String, String>.from(_matches[index].tacticalRoster);
      updatedRoster[tacticalPositionKey] = userId;
      _matches[index] = _matches[index].copyWith(tacticalRoster: updatedRoster);
      notifyListeners();
    }
  }

  void recordMatchScore(String matchId, String score) {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      _matches[index] = _matches[index].copyWith(
        finalScore: score,
        status: MatchStatus.completed,
      );
      notifyListeners();
    }
  }

  void voteForMVP(String matchId, String candidateUserId) {
    if (_currentUser == null) return;
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final currentAd = _matches[index];
      final updatedVotes = Map<String, String>.from(currentAd.mvpVotes);
      updatedVotes[_currentUser!.id] = candidateUserId;

      // Count votes to find current leading candidate
      final voteCounts = <String, int>{};
      for (var candidate in updatedVotes.values) {
        voteCounts[candidate] = (voteCounts[candidate] ?? 0) + 1;
      }

      String? leadingCandidate;
      int maxVotes = 0;
      voteCounts.forEach((candidate, count) {
        if (count > maxVotes) {
          maxVotes = count;
          leadingCandidate = candidate;
        }
      });

      _matches[index] = currentAd.copyWith(
        mvpVotes: updatedVotes,
        mvpUserId: leadingCandidate,
      );

      // Increment candidate's mvpCount in user model
      if (leadingCandidate != null) {
        final userIndex = _users.indexWhere((u) => u.id == leadingCandidate);
        if (userIndex != -1) {
          _users[userIndex] = _users[userIndex].copyWith(
            mvpCount: _users[userIndex].mvpCount + 1,
          );
          if (_currentUser!.id == leadingCandidate) {
            _currentUser = _users[userIndex];
          }
        }
      }

      notifyListeners();
    }
  }

  // Application Operations
  void applyToMatch(String matchId) {
    if (_currentUser == null) return;

    // Check if already applied
    final exists = _applications.any((app) => app.matchId == matchId && app.applicantId == _currentUser!.id);
    if (exists) return;

    final newApplication = Application(
      id: _uuid.v4(),
      matchId: matchId,
      applicantId: _currentUser!.id,
      applicantName: _currentUser!.name,
      applicantRating: _currentUser!.rating,
      applicantBio: _currentUser!.bio,
      status: ApplicationStatus.pending,
      dateTime: DateTime.now(),
    );

    _applications.add(newApplication);
    notifyListeners();
  }

  void acceptApplication(String applicationId) {
    final index = _applications.indexWhere((app) => app.id == applicationId);
    if (index == -1) return;

    final app = _applications[index];
    _applications[index] = app.copyWith(status: ApplicationStatus.accepted);

    // Update match spots needed
    final matchIndex = _matches.indexWhere((m) => m.id == app.matchId);
    if (matchIndex != -1) {
      final match = _matches[matchIndex];
      int remainingSpots = match.spotsNeeded - 1;
      if (remainingSpots <= 0) {
        _matches[matchIndex] = match.copyWith(
          spotsNeeded: 0,
          status: MatchStatus.completed, // Mark completed if filled (or simply full)
        );
      } else {
        _matches[matchIndex] = match.copyWith(spotsNeeded: remainingSpots);
      }
    }

    // Update player statistics
    final playerIndex = _users.indexWhere((u) => u.id == app.applicantId);
    if (playerIndex != -1) {
      _users[playerIndex] = _users[playerIndex].copyWith(
        totalMatchesPlayed: _users[playerIndex].totalMatchesPlayed + 1,
      );
    }

    notifyListeners();
  }

  void rejectApplication(String applicationId) {
    final index = _applications.indexWhere((app) => app.id == applicationId);
    if (index == -1) return;

    _applications[index] = _applications[index].copyWith(status: ApplicationStatus.rejected);
    notifyListeners();
  }

  // Review & Rating Operations
  void submitReview({
    required String matchId,
    required String matchTitle,
    required String revieweeId,
    required double rating,
    required String comment,
  }) {
    if (_currentUser == null) return;

    final newReview = Review(
      id: _uuid.v4(),
      matchId: matchId,
      matchTitle: matchTitle,
      reviewerId: _currentUser!.id,
      reviewerName: _currentUser!.name,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
      dateTime: DateTime.now(),
    );

    _reviews.insert(0, newReview);

    // Recalculate Average Rating for the reviewed user
    final userIndex = _users.indexWhere((u) => u.id == revieweeId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final userReviews = _reviews.where((r) => r.revieweeId == revieweeId).toList();
      double totalRatingSum = 0;
      for (var r in userReviews) {
        totalRatingSum += r.rating;
      }
      double average = totalRatingSum / userReviews.length;

      _users[userIndex] = user.copyWith(
        rating: double.parse(average.toStringAsFixed(1)),
        totalReviews: userReviews.length,
      );

      // If the reviewed user is also the current user, update session
      if (_currentUser!.id == revieweeId) {
        _currentUser = _users[userIndex];
      }
    }

    notifyListeners();
  }

  // Filtered Match Retrieval
  List<MatchAd> getFilteredMatches({
    required String searchCityOrDistrict,
    PositionType? positionFilter,
    bool? isFreeFilter,
  }) {
    return _matches.where((match) {
      // 1. Status Filter: only show active ads
      if (match.status != MatchStatus.active) return false;

      // 2. District/Location Search Filter
      if (searchCityOrDistrict.isNotEmpty) {
        final query = searchCityOrDistrict.toLowerCase();
        final matchDistrict = match.district.toLowerCase();
        final matchLocation = match.locationName.toLowerCase();
        final matchTitle = match.title.toLowerCase();
        if (!matchDistrict.contains(query) && 
            !matchLocation.contains(query) &&
            !matchTitle.contains(query)) {
          return false;
        }
      }

      // 3. Position Filter
      if (positionFilter != null && match.requiredPosition != positionFilter) {
        return false;
      }

      // 4. Price (Free) Filter
      if (isFreeFilter != null) {
        if (isFreeFilter && !match.isFree) return false;
        if (!isFreeFilter && match.isFree) return false;
      }

      return true;
    }).toList();
  }

  // Helper getters
  List<Application> getApplicationsForMatch(String matchId) {
    return _applications.where((app) => app.matchId == matchId).toList();
  }

  List<Review> getReviewsForUser(String userId) {
    return _reviews.where((r) => r.revieweeId == userId).toList();
  }

  List<Application> getMyApplications() {
    if (_currentUser == null) return [];
    return _applications.where((app) => app.applicantId == _currentUser!.id).toList();
  }

  List<MatchAd> getMyMatches() {
    if (_currentUser == null) return [];
    return _matches.where((match) => match.hostId == _currentUser!.id).toList();
  }
}
