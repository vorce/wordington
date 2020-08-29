# Benchmarks

Just some notes while trying to speed this thing up. Naive benchmarking :)

## Version 1

Just using `Stream`.

```elixir
def candidates(pattern, available) do
{time, candidates} =
    :timer.tc(fn ->
    @word_list_path
    |> File.stream!()
    |> Stream.map(&clean_word/1)
    |> Stream.filter(&matches?(&1, pattern, available))
    |> Enum.to_list()
    end)

IO.puts("Time taken: #{time / 1000}ms")
candidates
end
```

Result:

```
Time taken: 1642.439ms
.Time taken: 1508.787ms
.Time taken: 1407.257ms
.Time taken: 1519.826ms
.

Finished in 6.1 seconds
4 tests, 0 failures
```

## Version 2

Chunk the stream (in batches of 100 words each) and do work async.

```elixir
def candidates(pattern, available) do
  {time, candidates} =
    :timer.tc(fn ->
      @word_list_path
      |> File.stream!()
      |> Stream.chunk_every(100)
      |> Task.async_stream(fn chunk ->
        chunk
        |> Enum.map(&clean_word/1)
        |> Enum.filter(&matches?(&1, pattern, available))
      end)
      |> Stream.flat_map(&elem(&1, 1))
      |> Enum.to_list()
    end)

  IO.puts("Time taken: #{time / 1000}ms")
  candidates
end
```

Result:

```
Time taken: 920.821ms
.Time taken: 853.892ms
.Time taken: 859.37ms
.Time taken: 865.596ms
.

Finished in 3.5 seconds
4 tests, 0 failures
```

## Version 3

Tweaking the chunk size and max_concurrency.

```elixir
@chunk_size 1000
@max_concurrency System.schedulers_online() * 5

def candidates(pattern, available) do
  {time, candidates} =
    :timer.tc(fn ->
      @word_list_path
      |> File.stream!()
      |> Stream.chunk_every(@chunk_size)
      |> Task.async_stream(
        fn chunk ->
          chunk
          |> Enum.map(&clean_word/1)
          |> Enum.filter(&matches?(&1, pattern, available))
        end,
        max_concurrency: @max_concurrency
      )
      |> Stream.flat_map(&elem(&1, 1))
      |> Enum.to_list()
    end)

  IO.puts("Time taken: #{time / 1000}ms")
  candidates
end
```

Result:

```
Time taken: 852.915ms
.Time taken: 759.904ms
.Time taken: 699.812ms
.Time taken: 753.303ms
.

Finished in 3.1 seconds
4 tests, 0 failures
```
