<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index()
    {
        $posts = Post::orderBy('created_at', 'desc')
            ->with('user:id,name,image')
            ->withCount('comments', 'likes')
            ->with(['likes' => function ($like) {
                $like->where('user_id', auth()->user()->id);
            }])
            ->get()
            ->map(function ($post) {
                $post->self_like = $post->likes_count > 0;
                return $post;
            });

        return response()->json(['posts' => $posts], 200);
    }

    public function show($id)
    {
        $post = Post::with('user:id,name,image')
            ->withCount('comments', 'likes')
            ->findOrFail($id);

        return response()->json(['post' => $post], 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'body' => 'required|string',
        ]);

        $image = null;
        if ($request->image) {
            $image = str_starts_with($request->image, 'data:image')
                ? $request->image
                : 'data:image/png;base64,' . $request->image;
        }

        $post = Post::create([
            'user_id' => auth()->user()->id,
            'body' => $request->body,
            'image' => $image,
        ]);

        return response()->json([
            'message' => 'Post creado con éxito.',
            'post' => $post,
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['message' => 'Post no encontrado.'], 404);
        }

        if ($post->user_id != auth()->user()->id) {
            return response()->json(['message' => 'Permiso denegado.'], 403);
        }

        $request->validate([
            'body' => 'required|string',
        ]);

        $post->update(['body' => $request->body]);

        return response()->json([
            'message' => 'Post actualizado.',
            'post' => $post,
        ], 200);
    }

    public function destroy($id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['message' => 'Post no encontrado.'], 404);
        }

        if ($post->user_id != auth()->user()->id) {
            return response()->json(['message' => 'Permiso denegado.'], 403);
        }

        $post->delete();

        return response()->json(['message' => 'Post eliminado.'], 200);
    }
}
