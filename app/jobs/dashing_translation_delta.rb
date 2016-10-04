require 'txgh_web/stats/translation_delta'

Dashing.scheduler.every '1m' do
  def delta_for(repo_name)
    TranslationDelta.new(repo_name).delta
  end

  Dashing.send_event('lumosity', value: delta_for('lumoslabs/lumos_rails'))
  Dashing.send_event('ios', value: delta_for('lumoslabs/LumosityMobile'))
  Dashing.send_event('android', value: delta_for('lumoslabs/LumosityAndroid'))
end
