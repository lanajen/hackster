class License
  LICENSE_TYPES = {
    'http://opensource.org/licenses/Apache-2.0' => {
      name: 'Apache License 2.0 (Apache-2.0)',
      abbr: 'Apache-2.0', },
    'http://opensource.org/licenses/BSD-3-Clause' => {
      name: 'BSD 3-Clause "New" or "Revised" license (BSD-3-Clause)',
      abbr: 'BSD-3-Clause', },
    'http://opensource.org/licenses/BSD-2-Clause' => {
      name: 'BSD 2-Clause "Simplified" or "FreeBSD" license (BSD-2-Clause)',
      abbr: 'BSD-2-Clause', },
    'http://opensource.org/licenses/gpl-license' => {
      name: 'GNU General Public License (GPL)',
      abbr: 'GPL', },
    'http://opensource.org/licenses/lgpl-license' => {
      name: 'GNU Library or "Lesser" General Public License (LGPL)',
      abbr: 'LGPL', },
    'http://opensource.org/licenses/MIT' => {
      name: 'MIT license (MIT)',
      abbr: 'MIT', },
    'http://opensource.org/licenses/MPL-2.0' => {
      name: 'Mozilla Public License 2.0 (MPL-2.0)',
      abbr: 'MPL-2.0', },
    'http://opensource.org/licenses/CDDL-1.0' => {
      name: 'Common Development and Distribution License (CDDL-1.0)',
      abbr: 'CDDL-1.0', },
    'http://opensource.org/licenses/EPL-1.0' => {
      name: 'Eclipse Public License (EPL-1.0)',
      abbr: 'EPL-1.0', },
    'http://www.tapr.org/OHL' => {
      name: 'TAPR Open Hardware License (TAPR-OHL)',
      abbr: 'TAPR-OHL', },
    'http://www.balloonboard.org/docs/Balloon_License_0v2.pdf' => {
      name: 'Balloon Open Hardware License (BOHL)',
      abbr: 'BOHL', },
    'http://www.opencollector.org/hardlicense/hdpl.html' => {
      name: 'Hardware Design Public License Version 0.04 (HDPL)',
      abbr: 'HDPL', },
    'http://www.ohwr.org/projects/cernohl/wiki' => {
      name: 'CERN Open Hardware Licence (CERN-OHL)',
      abbr: 'CERN-OHL', },
    'http://solderpad.org/licenses/' => {
      name: 'Solderpad Hardware License (SHL)',
      abbr: 'SHL', },
    'http://creativecommons.org/licenses/by/4.0' => {
      name: 'Creative Commons Attribution CC BY (CC BY)',
      abbr: 'CC BY', },
    'http://creativecommons.org/licenses/by-sa/4.0' => {
      name: 'Creative Commons Attribution-ShareAlike CC BY-SA (CC BY-SA)',
      abbr: 'CC BY-SA', },
    'http://creativecommons.org/licenses/by-nd/4.0' => {
      name: 'Creative Commons Attribution-NoDerivs CC BY-ND (CC BY-ND)',
      abbr: 'CC BY-ND', },
    'http://creativecommons.org/licenses/by-nc/4.0' => {
      name: 'Creative Commons Attribution-NonCommercial CC BY-NC (CC BY-NC)',
      abbr: 'CC BY-NC', },
    'http://creativecommons.org/licenses/by-nc-sa/4.0' => {
      name: 'Creative Commons Attribution-NonCommercial-ShareAlike CC BY-NC-SA (CC BY-NC-SA)',
      abbr: 'CC BY-NC-SA', },
    'http://creativecommons.org/licenses/by-nc-nd/4.0' => {
      name: 'Creative Commons Attribution-NonCommercial-NoDerivs CC BY-NC-ND (CC BY-NC-ND)',
      abbr: 'CC BY-NC-ND', },
  }

  attr_reader :url, :name, :abbr

  def self.all
    LICENSE_TYPES.map do |url, attrs|
      new url
    end.sort_by{ |l| l.name }
  end

  def self.all_with_abbr
    LICENSE_TYPES.inject({}) { |h, (k, v)| h[k] = v[:abbr]; h }
  end

  def initialize url
    @url = url
    @name = LICENSE_TYPES[url][:name]
    @abbr = LICENSE_TYPES[url][:abbr]
  end
end