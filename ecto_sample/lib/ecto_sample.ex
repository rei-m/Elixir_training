defmodule EctoSample.Repo do
  use Ecto.Repo,
    otp_app: :ecto_sample
end

defmodule EctoSample.Weather do
  use Ecto.Model

  # Define Schema
  schema "weather" do
    field :city   # default type string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp,    :float, default: 0.0
  end

end

defmodule EctoSample.App do
  import Ecto.Query
  alias EctoSample.Weather
  alias EctoSample.Repo

  def sample_query do
    query = from w in Weather,
      where: w.prcp > 0 or is_nil(w.prcp),
      select: w
    Repo.all(query)
  end

end
