@extends('layout')

@section('content')

<h2>Create Post</h2>

<form action="/posts" method="POST">

    @csrf

    <input
        type="text"
        name="title"
        placeholder="Title"
    >

    <br><br>

    <textarea
        name="content"
        placeholder="Content"
    ></textarea>

    <br><br>

    <button type="submit">
        Save
    </button>

</form>

@endsection