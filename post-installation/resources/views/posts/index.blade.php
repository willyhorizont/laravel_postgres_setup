@extends('layout')

@section('content')

<a href="/">Home</a>

<a href="/posts/create">Create Post</a>

<hr>

@foreach ($posts as $post)

    <h2>{{ $post->title }}</h2>

    <p>{{ $post->content }}</p>

    <a href="/posts/{{ $post->id }}">
        View
    </a>

    <a href="/posts/{{ $post->id }}/edit">
        Edit
    </a>

    <form
        action="/posts/{{ $post->id }}"
        method="POST"
    >
        @csrf
        @method('DELETE')

        <button type="submit">
            Delete
        </button>
    </form>

    <hr>

@endforeach

@endsection