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
