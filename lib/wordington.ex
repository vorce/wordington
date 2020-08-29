defmodule Wordington do
  @moduledoc false

  @word_list_path "ss100_utf8_2.txt"

  @gap_character "_"

  # These numbers have been arrived at by just checking the times reported by
  # tc for the test suite on my laptop. Highly unscientific. See `benchmark.md`
  @chunk_size 1000
  @max_concurrency System.schedulers_online() * 5

  @doc ~S"""
  Returns word candidates that matches the `pattern` and contains only letters
  in `available`.

  By default the swedish word list (ss100_utf8_2.txt) will be used, if you want
  to use a custom word list you can specify it as an option:

  `candidates(pattern, available, word_list_path: "path/to/my/words.txt")`

  ## Examples

      iex> Wordington.candidates(["g", "_", "_", "_", "_", "l"], ["d", "a", "g", "l", "i", "e", "n"])
      ["genial"]
  """
  @spec candidates(
          pattern :: list(String.t()),
          available :: list(String.t()),
          opts :: Keyword.t()
        ) :: list(String.t())
  def candidates(pattern, available, opts \\ []) do
    word_list_path = Keyword.get(opts, :word_list_path, @word_list_path)

    word_list_path
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
  end

  defp clean_word(word) do
    word
    |> String.downcase()
    |> String.trim()
  end

  def matches?(word, known, available) do
    all_letters_available?(word, available) and
      matches_pattern?(word, known)
  end

  @spec all_letters_available?(word :: String.t(), available :: list(String.t())) :: boolean()
  defp all_letters_available?(word, available) do
    word_char_frequency =
      word
      |> String.graphemes()
      |> char_frequency()

    available_char_frequency = char_frequency(available)

    word_fits_in_available? =
      Enum.all?(word_char_frequency, fn {char, freq} ->
        available_freq = Map.get(available_char_frequency, char, 0)
        freq <= available_freq
      end)

    word_fits_in_available?
  end

  @spec char_frequency(chars :: list(String.t())) :: map()
  defp char_frequency(chars) do
    Enum.reduce(chars, %{}, fn char, acc ->
      Map.update(acc, char, 1, fn existing -> existing + 1 end)
    end)
  end

  defp matches_pattern?(word, pattern) when is_binary(word) do
    String.length(word) == length(pattern) and
      matches_pattern(String.graphemes(word), pattern)
  end

  defp matches_pattern(chars, pattern) when is_list(chars) do
    chars
    |> Enum.with_index()
    |> Enum.all?(fn {char, index} ->
      pattern_char = Enum.at(pattern, index)
      pattern_char == @gap_character or pattern_char == char
    end)
  end
end
