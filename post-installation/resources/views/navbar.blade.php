<nav>
    <a href="/">Home</a>
    <h2>Laravel PostgreSQL CRUD</h2>
    @if (auth()->check())

        <p>
            Logged in as:
            {{ auth()->user()->name }}
        </p>

        <form method="POST" action="/logout">
            @csrf

            <button type="submit">
                Logout
            </button>
        </form>

    @else

        <a href="/login">
            Login
        </a>

        <a href="/register">
            Register
        </a>

    @endif
</nav>

<hr>