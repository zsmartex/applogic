require "jennifer"

abstract class BaseModel < Jennifer::Model::Base
  def self.find(id)
    all.where { c("id") == id }.first
  end

  def self.find_by(**opts)
    data = all
    opts.each do |k, v|
      data = data.where { c(k.to_s) == v }
    end
    data.first
  end

  def self.find_or_create_by(**opts, &block)
    yield (find_by(**opts) || create(**opts))
  end

  def self.find!(id)
    all.where { c("id") == id }.first!
  end

  def self.find_by!(**opts)
    data = all
    opts.each do |k, v|
      data = data.where { c(k.to_s) == v }
    end
    data.first!
  end
end
