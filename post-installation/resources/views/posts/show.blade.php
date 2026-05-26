@extends('layout')

@section('content')

<h1>{{ $post->title }}</h1>

<p>{{ $post->content }}</p>

<p>creator: {{ $post->user->name }}</p>

<a href="/posts">
    Back
</a>

@endsection