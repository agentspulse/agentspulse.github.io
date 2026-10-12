module Jekyll
  class TutorialArchivePage < Page
    def initialize(site, archive_type, archive_value, documents)
      @site = site
      @base = site.source

      slug = Jekyll::Utils.slugify(archive_value)
      @dir = File.join('tutorials', archive_type == 'tags' ? 'tag' : 'category', slug)
      @name = 'index.html'

      process(@name)
      self.content = ''

      self.data = {
        'layout' => 'archive',
        'title' => archive_value,
        'type' => archive_type,
        'collection_name' => 'tutorials',
        'documents' => documents.sort_by { |doc| doc.date || Time.at(0) }.reverse,
        'sitemap' => false,
        'seo_title' => archive_type == 'tags' ? "#{archive_value} AI Tag" : "#{archive_value} AI Category",
        'description' => archive_type == 'tags' ?
          "Browse tutorial articles tagged #{archive_value} on AgentsPulse, including frontier AI papers, surveys, and practical explainers." :
          "Browse tutorial articles in the #{archive_value} category on AgentsPulse, including frontier AI papers, surveys, and practical explainers."
      }
    end
  end

  class TutorialArchivesGenerator < Generator
    safe true
    priority :low

    def generate(site)
      tutorials = site.collections['tutorials']
      return unless tutorials

      build_archives(site, tutorials.docs, 'tags')
      build_archives(site, tutorials.docs, 'categories')
    end

    private

    def build_archives(site, documents, field)
      grouped = Hash.new { |hash, key| hash[key] = [] }

      documents.each do |document|
        Array(document.data[field]).each do |value|
          next if value.to_s.strip.empty?

          grouped[value] << document
        end
      end

      grouped.each do |value, docs|
        site.pages << TutorialArchivePage.new(site, field, value, docs)
      end

      puts "Generated #{grouped.size} tutorial #{field} archives"
    end
  end
end

# Controlled in-place ingestion: source artifacts stay in their Skill output folder.
Jekyll::Hooks.register :site, :post_read do |site|
  collection = site.collections['tutorials']
  next unless collection
  root = File.realpath(site.source)
  Array(site.config['tutorial_artifact_sources']).each do |source|
    relative = source.to_s
    unless relative.match?(/\A(?:技术文章写作|technical-article-writing)_\d{8}_\d{6}\/[^\/]+\.md\z/)
      raise Jekyll::Errors::FatalException, "Invalid tutorial artifact source"
    end
    path = File.realpath(File.join(root, relative))
    unless path.start_with?(root + File::SEPARATOR)
      raise Jekyll::Errors::FatalException, "Tutorial artifact must remain inside the repository"
    end
    document = Jekyll::Document.new(path, :site => site, :collection => collection)
    document.read
    # Jekyll otherwise infers a category from the private output directory.
    document.data['categories'] = Array(document.data['categories']).reject { |value| value.to_s.match?(/\A(?:技术文章写作|technical-article-writing)_\d{8}_\d{6}\z/) }
    unless document.data['permalink'].to_s.match?(/\A\/tutorials\/[a-z0-9][a-z0-9-]*\/\z/)
      raise Jekyll::Errors::FatalException, "Tutorial artifact requires an explicit /tutorials/ permalink"
    end
    if collection.docs.any? { |existing| existing.url == document.url }
      raise Jekyll::Errors::FatalException, "Duplicate tutorial artifact permalink"
    end
    collection.docs << document
  end
end
