<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PostController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $posts = Post::with('user')->latest()->get();

        return view('posts.index', [
            'posts' => $posts,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        if (auth()->check()) {
            return view('posts.create');
        }
        abort(403);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        if (auth()->check()) {
            Post::create([
                'user_id' => Auth::id(),
                'title' => $request->title,
                'content' => $request->content,
            ]);
            return;
        }

        abort(403);
    }

    /**
     * Display the specified resource.
     */
    public function show(Post $post)
    {
        return view('posts.show', [
            'post' => $post,
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Post $post)
    {
        if (auth()->check() && ($post->user_id == auth()->id())) {
            return view('posts.edit', [
                'post' => $post,
            ]);
        }
        abort(403);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Post $post)
    {
        if (auth()->check() && ($post->user_id == auth()->id())) {
            $post->update([
                'title' => $request->title,
                'content' => $request->content,
            ]);
            return;
        }

        abort(403);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Post $post)
    {
        if (auth()->check() && ($post->user_id == auth()->id())) {
            $post->delete();
            return;
        }

        abort(403);
    }
}
