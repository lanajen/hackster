class SchematicWidget < EmbedWidget
  def valid_repo?
    embed.schematic_repo?
  end
end