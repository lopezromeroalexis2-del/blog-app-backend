<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\Post;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    public function index($id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['message' => 'Post no encontrado.'], 404);
        }

        $comments = $post->comments()->with('user:id,name,image')->get();

        return response()->json(['comments' => $comments], 200);
    }

    public function store(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['message' => 'Post no encontrado.'], 404);
        }

        $request->validate([
            'comment' => 'required|string',
        ]);

        Comment::create([
            'comment' => $request->comment,
            'post_id' => $id,
            'user_id' => auth()->user()->id,
        ]);

        return response()->json(['message' => 'Comentario creado con éxito.'], 200);
    }

    public function update(Request $request, $id)
    {
        $comment = Comment::find($id);

        if (!$comment) {
            return response()->json(['message' => 'Comentario no encontrado.'], 404);
        }

        if ($comment->user_id != auth()->user()->id) {
            return response()->json(['message' => 'Permiso denegado.'], 403);
        }

        $request->validate([
            'comment' => 'required|string',
        ]);

        $comment->update(['comment' => $request->comment]);

        return response()->json(['message' => 'Comentario actualizado.'], 200);
    }

    public function destroy($id)
    {
        $comment = Comment::find($id);

        if (!$comment) {
            return response()->json(['message' => 'Comentario no encontrado.'], 404);
        }

        if ($comment->user_id != auth()->user()->id) {
            return response()->json(['message' => 'Permiso denegado.'], 403);
        }

        $comment->delete();

        return response()->json(['message' => 'Comentario eliminado.'], 200);
    }
}
