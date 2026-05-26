@extends('layout')

@section('content')

<h1>Posts | Laravel PostgreSQL CRUD</h1>

@if (auth()->check())
    <a href="/posts/create">Create Post</a>
@endif

<hr>

@foreach ($posts as $post)

    <h2>{{ $post->title }}</h2>

    <p>{{ $post->content }}</p>

    <p>creator: {{ $post->user->name }}</p>

    <a href="/posts/{{ $post->id }}">
        View
    </a>

    @if (auth()->check())
        @if (auth()->id() == $post->user_id)
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
        @endif
    @endif

    <hr>

@endforeach

@endsection