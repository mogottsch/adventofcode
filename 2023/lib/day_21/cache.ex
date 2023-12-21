defmodule Day_21.Cache do
  @cache_key_prefix :day_12_cache
  def setup() do
    :ets.new(@cache_key_prefix, [
      # gives us key=>value semantics
      :set,

      # allows any process to read/write to our table
      :public,

      # allow the ETS table to access by it's name, `:myapp_users`
      :named_table,

      # favor read-locks over write-locks
      read_concurrency: true,

      # internally split the ETS table into buckets to reduce
      # write-lock contention
      write_concurrency: true
    ])
  end

  def get(key) do
    case :ets.lookup(@cache_key_prefix, key) do
      [{_key, value}] -> value
      _ -> nil
    end
  end

  def put(key, value) do
    :ets.insert(@cache_key_prefix, {key, value})
  end
end
