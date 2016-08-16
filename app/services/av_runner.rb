require "open3"

class AvRunner
  def perform(scan)
    set_checksums_and_file_size scan

    scan_results = scan.engines.inject({}) do |memo, engine|
      engine_class = "AvRunner::#{engine.to_s.camelize}".constantize
      memo[engine] = engine_class.new(scan).perform!
      memo
    end

    scan.av_checked! scan_results
  end

  private

  def set_checksums_and_file_size(scan)
    md5 = Digest::MD5.file(scan.file_path).hexdigest
    sha1 = Digest::SHA1.file(scan.file_path).hexdigest
    sha256 = Digest::SHA256.file(scan.file_path).hexdigest
    file_size = File.size(scan.file_path)
    scan.update!(md5: md5, sha1: sha1, sha256: sha256, file_size: file_size)
  end
end
