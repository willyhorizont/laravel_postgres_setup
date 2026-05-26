@extends('layout')

@section('content')

<a href="/">Home</a>

<a href="/login">Login</a>

<h1>Register</h1>

<form method="POST" action="/register">
    @csrf

    <input type="text" name="name" placeholder="name">

    <input type="email" name="email" placeholder="email">

    <input type="password" name="password" placeholder="password">

    <button type="submit">
        Register
    </button>
</form>

@endsection