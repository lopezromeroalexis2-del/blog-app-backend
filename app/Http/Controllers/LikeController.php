<?php

namespace App\Http\Controllers;

use App\Models\Like;
use App\Models\Post;

class LikeController extends Controller
{
    public function likeOrUnlike($id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['message' => 'Post no encontrado.'], 404);
        }

        $like = $post->likes()->where('user_id', auth()->user()->id)->first();

        if (!$like) {
            Like::create([
                'post_id' => $id,
                'user_id' => auth()->user()->id,
            ]);

            return response()->json(['message' => 'Liked'], 200);
        }

        $like->delete();

        return response()->json(['message' => 'Unliked'], 200);
    }
}
