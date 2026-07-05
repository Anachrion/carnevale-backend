# Serializers render domain records to the plain Hashes the API returns, keeping presentation out
# of the models and controllers (one convention: `Serializer.new(record, **context).as_json`, B-P2-8).
class SpellSerializer
  def initialize(spell)
    @spell = spell
  end

  def as_json
    {
      id: @spell.id,
      name: @spell.name,
      discipline: @spell.discipline,
      cost: @spell.cost,
      difficulty: @spell.difficulty,
      cantrip: @spell.cantrip,
      description: @spell.description
    }
  end
end
