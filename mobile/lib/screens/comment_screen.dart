import 'package:flutter/material.dart';
import '../constant.dart';
import '../models/api_response.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import 'login.dart';

class CommentScreen extends StatefulWidget {
  final int? postId;

  const CommentScreen({super.key, this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<dynamic> _commentsList = [];
  bool _loading = true;
  int _userId = 0;
  int _editCommentId = 0;
  final TextEditingController _txtCommentController = TextEditingController();
  final TextEditingController _txtEditCommentController = TextEditingController();

  Future<void> _getComments() async {
    _userId = await getUserId();
    ApiResponse response = await getComments(widget.postId ?? 0);

    if (!mounted) return;

    if (response.error == null) {
      setState(() {
        _commentsList = response.data as List<dynamic>;
        _loading = false;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void _createComment() async {
    ApiResponse response =
        await createComment(widget.postId ?? 0, _txtCommentController.text);

    if (!mounted) return;

    if (response.error == null) {
      _txtCommentController.clear();
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _editComment() async {
    ApiResponse response =
        await editComment(_editCommentId, _txtEditCommentController.text);

    if (!mounted) return;

    if (response.error == null) {
      _editCommentId = 0;
      _txtEditCommentController.clear();
      Navigator.of(context).pop();
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _deleteComment(int commentId) async {
    ApiResponse response = await deleteComment(commentId);

    if (!mounted) return;

    if (response.error == null) {
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _showEditDialog(Comment comment) {
    _editCommentId = comment.id ?? 0;
    _txtEditCommentController.text = comment.comment ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextFormField(
            controller: _txtEditCommentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Edit your comment',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_txtEditCommentController.text.isNotEmpty) {
                  _editComment();
                }
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () {
                      return _getComments();
                    },
                    child: ListView.builder(
                      itemCount: _commentsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Comment comment = _commentsList[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black12, width: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: SizedBox(
                                          width: 35,
                                          height: 35,
                                          child: buildBase64Image(comment.user?.image, width: 35, height: 35),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${comment.user!.name}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  comment.user!.id == _userId
                                      ? PopupMenuButton(
                                          child: const Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Icon(Icons.more_vert, color: Colors.black54),
                                          ),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            )
                                          ],
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showEditDialog(comment);
                                            } else if (value == 'delete') {
                                              _deleteComment(comment.id ?? 0);
                                            }
                                          },
                                        )
                                      : const SizedBox()
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text('${comment.comment}'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black26, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _txtCommentController,
                    decoration: const InputDecoration(
                      hintText: 'Comment',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.black38),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: () {
                    if (_txtCommentController.text.isNotEmpty) {
                      _createComment();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
