import 'package:flutter/material.dart';
import '../constant.dart';
import '../models/api_response.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import 'comment_screen.dart';
import 'login.dart';
import 'post_form.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int _userId = 0;
  bool _loading = true;

  Future<void> retrievePosts() async {
    _userId = await getUserId();
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void _handlePostLikeUnlike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);
    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  @override
  void initState() {
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () {
              return retrievePosts();
            },
            child: ListView.builder(
              itemCount: _postList.length,
              itemBuilder: (BuildContext context, int index) {
                Post post = _postList[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: buildBase64Image(post.user?.image, width: 38, height: 38),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${post.user!.name}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          post.user!.id == _userId
                              ? PopupMenuButton(
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.more_vert, color: Colors.black),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Editar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PostForm(
                                            title: 'Editar Publicación',
                                            post: post,
                                          ),
                                        ),
                                      );
                                    } else {
                                      _handleDeletePost(post.id ?? 0);
                                    }
                                  },
                                )
                              : const SizedBox()
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${post.body}'),
                      if (post.image != null && post.image!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: buildBase64Image(post.image, width: double.infinity, height: 200, fit: BoxFit.cover),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              post.selfLiked == true
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: post.selfLiked == true ? Colors.red : Colors.black38,
                            ),
                            onPressed: () {
                              _handlePostLikeUnlike(post.id ?? 0);
                            },
                          ),
                          Text('${post.likesCount ?? 0}'),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(
                              Icons.comment,
                              color: Colors.black38,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                    postId: post.id,
                                  ),
                                ),
                              );
                            },
                          ),
                          Text('${post.commentsCount ?? 0}'),
                        ],
                      ),
                      const Divider(thickness: 1),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
