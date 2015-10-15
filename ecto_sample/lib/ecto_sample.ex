defmodule EctoSample.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    tree = [worker(EctoSample.Repo, [])]
    opts = [name: EctoSample.Sup, strategy: :one_for_one]
    Supervisor.start_link(tree, opts)
  end
end


defmodule EctoSample.Repo do
  use Ecto.Repo, otp_app: :ecto_sample
end

defmodule Weather do
  use Ecto.Model

  # Define Schema
  schema "weather" do
    belongs_to :city, City
    field :wdate, Ecto.Date
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp, :float, default: 0.0
    timestamps
  end

end

defmodule City do
  use Ecto.Model

  schema "cities" do
    has_many :local_weather, Weather
    belongs_to :country, Country
    field :name, :string
  end

end

defmodule Country do
  use Ecto.Model
  schema "countries" do
    has_many :cities, City
    # here we associate the `:local_weather` from every City that belongs_to
    # a Country through that Country's `has_many :cities, City` association
    has_many :weather, through: [:cities, :local_weather]
    field :name, :string
  end
end

defmodule EctoSample do
  import Ecto.Query

  def sample_query do
    query = from w in Weather,
      where: w.prcp <= 0.0 or is_nil(w.prcp),
      select: w
    EctoSample.Repo.all(query)
  end

end
