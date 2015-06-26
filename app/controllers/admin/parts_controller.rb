class Admin::PartsController < Admin::BaseController
  def index
    title "Admin / Parts - #{safe_page_params}"
    @fields = {
      'created_at' => 'parts.created_at',
      'name' => 'parts.name',
      'workflow_state' => 'parts.workflow_state',
    }

    params[:sort_by] ||= 'created_at'
    params[:per_page] ||= 100

    @parts = filter_for Part.not_invalid, @fields
  end

  def new
    @part = Part.new
    @parts = []#Part.approved
  end

  def create
    @part = Part.new(params[:part])

    if @part.save
      merge_parts
      redirect_to admin_parts_path, :notice => 'New part created'
    else
      render :new
    end
  end

  def edit
    @part = Part.find(params[:id])
  end

  def update
    @part = Part.find(params[:id])

    if @part.update_attributes(params[:part])
      merge_parts
      redirect_to admin_parts_path, :notice => 'Part successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @part = Part.find(params[:id])
    @part.destroy
    redirect_to admin_parts_path, :notice => 'Part successfuly deleted'
  end

  def duplicates
    @parts = Part.not_invalid.group("lower(name)").having("count(*) > 1").order("count_all desc").count
  end

  def merge_new
    @parts = if params[:part_ids]
      Part.where(id: params[:part_ids])
    else
      Part.where("lower(name) = ?", params[:name].downcase)
    end

    attributes = @parts.inject({}) do |mem, part|
      part.attributes.delete_if{|k, v| k.in? %w(id quantity total_cost partable_type partable_id created_at updated_at position comment websites private counters_cache workflow_state) or v.blank? }.merge mem
    end

    @part = Part.new attributes
    @part.part_joins = @parts.map{|p| p.part_joins }.flatten
  end

  def extract
    respond_to do |format|
      format.csv { send_data Part.to_csv }
    end
  end

  private
    def merge_parts
      if params[:merge_parts]
        part_joins = PartJoin.where(part_id: params[:merge_parts].to_a - [@part.id.to_s])
        part_joins.update_all(part_id: @part.id)
        @part.update_counters only: [:projects]
        Part.where(id: params[:merge_parts].to_a - [@part.id.to_s]).update_all(workflow_state: :retired)
      end
    end
end