<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $attrs = $request->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6|confirmed',
        ]);

        $attrs['password'] = Hash::make($attrs['password']);

        $user = User::create($attrs);

        $token = $user->createToken('secret')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    public function login(Request $request)
    {
        $attrs = $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6',
        ]);

        if (!Auth::attempt($attrs)) {
            return response()->json([
                'message' => 'Credenciales inválidas.',
            ], 403);
        }

        $user = Auth::user();
        $token = $user->createToken('secret')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    public function logout()
    {
        auth()->user()->tokens()->delete();

        return response()->json([
            'message' => 'Sesión cerrada correctamente.',
        ], 200);
    }

    public function user()
    {
        return response()->json([
            'user' => auth()->user(),
        ], 200);
    }

    public function update(Request $request)
    {
        $attrs = $request->validate([
            'name' => 'required|string',
        ]);

        $user = auth()->user();

        if ($request->image) {
            $user->image = $this->saveImage($request->image);
        }

        $user->name = $attrs['name'];
        $user->save();

        return response()->json([
            'message' => 'User updated.',
            'user' => $user
        ], 200);
    }

    private function saveImage($image): string
    {
        if (str_starts_with($image, 'data:image')) {
            return $image;
        }

        return 'data:image/png;base64,' . $image;
    }
}
