import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images or camera usage
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:transport_sante/widgets/home/chat_widgets.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart' as old_styles;
import '../styles/bottom_navigation_bar_styles.dart';
import '../api/user_api.dart';
import '../api/chat_api.dart';
import '../services/methods/chat_methods.dart';
import '../widgets/home/chat_widgets.dart' as home_chat;
import 'dart:async';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';

class ChatScreen extends StatefulWidget {
  final String missionId;

  const ChatScreen({
    Key? key,
    required this.missionId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  String? currentUserId;
  String? currentUserName;
  bool isLoading = true;
  IO.Socket? _socket;
  Timer? _refreshTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAppActive = true;
  DateTime _lastScrollTime = DateTime.now();

  // Cache des messages et optimisation de la mémoire
  static const int _maxCachedMessages = 50;
  final Map<String, String> _userNameCache = {};
  final Set<String> _loadingImages = {};
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _messagesPerPage = 20;

  // Optimisation du scroll
  bool _shouldAnimateScroll = true;

  // Variables d'état
  bool _isFirstLoad = true;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  void _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Do something with the captured image
    }
  }

  void _openFilePicker() async {
    // Implement file picker for PDF or image
  }

  void _sendAudio() async {
    // Start/stop audio recording

    // Recording implementation here
  }

  void _showEmojiPicker() {
    // Open emoji picker (optional, you can use a package like emoji_picker_flutter)
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _setupAnimations();

    if (!_isInitialized) {
      _initializeChat();
      _isInitialized = true;
    }

    _setupRefreshTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _isAppActive = state == AppLifecycleState.resumed;
    });
    ChatMethods.updateAppLifecycleState(state);
  }

  void _setupRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && !isLoading && _isAppActive) {
        _loadMessageHistory(silent: true);
      }
    });
  }

  Future<void> _initializeChat() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      if (!mounted) return;

      setState(() {
        currentUserId = userInfo['id'].toString();
        currentUserName = '${userInfo['nom']} ${userInfo['prenom']}';
      });

      await _setupSocketConnection();
      await _loadMessageHistory();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _setupSocketConnection() async {
    ChatApi.initializeSocket();
    ChatApi.socket?.on('message', _handleNewMessage);
  }

  void _handleNewMessage(dynamic data) {
    if (data['mission_id'].toString() == widget.missionId) {
      // Récupérer les informations de l'expéditeur
      ChatApi.getUserInfo(data['sender_id'].toString()).then((userInfo) {
        String senderName;
        if (userInfo != null) {
          final nom = userInfo['nom'] ?? '';
          final prenom = userInfo['prenom'] ?? '';
          senderName = '$prenom $nom';
        } else {
          senderName = data['sender'] ?? 'Utilisateur inconnu';
        }

        if (mounted) {
          setState(() {
            messages.insert(0, {
              'sender': senderName,
              'time': DateTime.now().toString().substring(11, 16),
              'message': data['message'] ?? '',
              'image': data['image_url'] ?? '',
              'isCurrentUser': data['sender_id'] == currentUserId,
            });
          });
          _scrollToBottom();
        }
      });
    }
  }

  Future<void> _loadMessageHistory({bool silent = false}) async {
    if (!mounted || widget.missionId.isEmpty) return;

    try {
      if (!silent) setState(() => isLoading = true);

      final history = await ChatMethods.loadMessageHistory(widget.missionId);
      if (!mounted) return;

      if (history.isNotEmpty) {
        final processedMessages = await Future.wait(
          history.reversed.map((msg) async {
            final senderId = msg['sender_id'].toString();
            // Récupérer les informations complètes de l'utilisateur
            final userInfo = await ChatApi.getUserInfo(senderId);
            String senderName;
            
            if (userInfo != null) {
              final nom = userInfo['nom'] ?? '';
              final prenom = userInfo['prenom'] ?? '';
              senderName = '$prenom $nom';
            } else {
              senderName = 'Utilisateur inconnu';
            }

            return {
              'sender': senderName,
              'time': ChatMethods.formatMessageTime(msg['timestamp']),
              'message': msg['message'] ?? '',
              'image': msg['image_url'] ?? '',
              'isCurrentUser': senderId == currentUserId,
            };
          }),
        );

        if (mounted) {
          setState(() {
            messages = processedMessages;
            if (!silent) isLoading = false;
          });
          _scrollToBottom();
        }
      } else if (mounted && !silent) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() => isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        currentUserId == null ||
        currentUserName == null) {
      return;
    }

    try {
      final messageContent = _messageController.text.trim();
      final userInfo = await UserApi.getUserInfo();
      final nom = userInfo['nom'] ?? '';
      final prenom = userInfo['prenom'] ?? '';
      final fullName = '$prenom $nom';

      await ChatApi.sendMessage(
        sender: fullName,
        message: messageContent,
        userId: currentUserId!,
        missionId: widget.missionId,
      );
      _messageController.clear();
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  void _handleImageLoaded(String imageUrl) {
    ChatMethods.handleImageLoaded(imageUrl);
  }

  void _setupAnimations() {
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _refreshTimer?.cancel();
    _scrollController.dispose();
    ChatMethods.dispose();
    _socket = null;
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLargeScreen = AppDimensions.isLargeScreen(context);
    final isTablet = AppDimensions.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: ChatWidgets.buildAppBar(
        context: context,
        title: 'Chat',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 800 : constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: isLargeScreen
                        ? (constraints.maxWidth - 800) / 2
                        : AppDimensions.getContentPadding(context),
                  ),
                  child: messages.isEmpty
                      ? (isLoading
                          ? Center(
                              child: SizedBox
                                  .shrink()) // Affiche rien, mais garde l'UI
                          : ChatWidgets.buildEmptyChat(context))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              _lastScrollTime = DateTime.now();
                              _shouldAnimateScroll = false;
                            }
                            return true;
                          },
                          child: ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.getSpacing(context),
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: ChatWidgets.buildMessageBubble(
                                  key: ValueKey(message['time'] +
                                      (message['message'] ??
                                          '')), // plus robuste
                                  context: context,
                                  message: message,
                                  isMe: message['isCurrentUser'] ?? false,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 800 : constraints.maxWidth,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal:
                      isLargeScreen ? (constraints.maxWidth - 800) / 2 : 0,
                ),
                child: ChatWidgets.buildMessageInput(
                  context: context,
                  controller: _messageController,
                  onSend: _sendMessage,
                  onCamera: () => ChatMethods.takePhoto(
                    widget.missionId,
                    currentUserId!,
                    currentUserName!,
                  ),
                  onGallery: () => ChatMethods.sendImage(
                    widget.missionId,
                    currentUserId!,
                    currentUserName!,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}