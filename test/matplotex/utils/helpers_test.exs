defmodule Matplotex.Utils.HelpersTest do
  use ExUnit.Case
  alias Matplotex.Utils.Helpers

  describe "run_validator/2" do
    test "return error for invalid input" do
      validator = %{"width" => fn x -> is_number(x) end, "height" => fn x -> is_number(x) end}

      params = %{"width" => 123, "height" => "nonumber"}
      assert_raise Matplotex.InputError, fn -> Helpers.run_validator(true, validator, params) end
    end
  end
end
