@extends('layout')

@section('content')

<h2>{{ $post->title }}</h2>

<p>{{ $post->content }}</p>

<a href="/posts">
    Back
</a>

@endsection