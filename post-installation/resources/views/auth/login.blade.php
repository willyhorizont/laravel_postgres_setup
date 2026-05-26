@extends('layout')

@section('content')

<a href="/">Home</a>

<a href="/register">Register</a>

<h1>Login</h1>

<form method="POST" action="/login">
    @csrf

    <input type="email" name="email" placeholder="email">

    <input type="password" name="password" placeholder="password">

    <button type="submit">
        Login
    </button>
</form>

@endsection