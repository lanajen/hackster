class License
  LICENSE_TYPES = {
    'http://opensource.org/licenses/Apache-2.0' => {
      name: 'Apache License 2.0 (Apache-2.0)',
      abbr: 'Apache-2.0', },
    'http://opensource.org/licenses/BSD-3-Clause' => {
      name: 'BSD 3-Clause "New" or "Revised" license (BSD-3-Clause)',
      abbr: 'BSD-3-Clause',
      deprecated: true, },
    'http://opensource.org/licenses/BSD-2-Clause' => {
      name: 'BSD 2-Clause "Simplified" or "FreeBSD" license (BSD-2-Clause)',
      abbr: 'BSD-2-Clause',
      deprecated: true, },
    'http://opensource.org/licenses/GPL-3.0' => {
      name: 'GNU General Public License, version 3 or later (GPL3+)',
      abbr: 'GPL', },
    'http://opensource.org/licenses/gpl-license' => {
      name: 'GNU General Public License (GPL)',
      abbr: 'GPL',
      deprecated: true },
    'http://opensource.org/licenses/lgpl-license' => {
      name: 'GNU Lesser General Public License version 3 or later (LGPL3+)',
      abbr: 'LGPL', },
    'http://opensource.org/licenses/MIT' => {
      name: 'MIT license (MIT)',
      abbr: 'MIT', },
    'http://opensource.org/licenses/MPL-2.0' => {
      name: 'Mozilla Public License 2.0 (MPL-2.0)',
      abbr: 'MPL-2.0', },
    'http://opensource.org/licenses/CDDL-1.0' => {
      name: 'Common Development and Distribution License (CDDL-1.0)',
      abbr: 'CDDL-1.0',
      deprecated: true, },
    'http://opensource.org/licenses/EPL-1.0' => {
      name: 'Eclipse Public License (EPL-1.0)',
      abbr: 'EPL-1.0',
      deprecated: true, },
    'http://www.tapr.org/OHL' => {
      name: 'TAPR Open Hardware License (TAPR-OHL)',
      abbr: 'TAPR-OHL', },
    'http://www.balloonboard.org/docs/Balloon_License_0v2.pdf' => {
      name: 'Balloon Open Hardware License (BOHL)',
      abbr: 'BOHL',
      deprecated: true, },
    'http://www.opencollector.org/hardlicense/hdpl.html' => {
      name: 'Hardware Design Public License Version 0.04 (HDPL)',
      abbr: 'HDPL',
      deprecated: true, },
    'http://www.ohwr.org/projects/cernohl/wiki' => {
      name: 'CERN Open Hardware Licence (CERN-OHL)',
      abbr: 'CERN-OHL',
      deprecated: true, },
    'http://www.ohwr.org/documents/294' => {
      name: 'CERN Open Hardware Licence version 1.2 or later (CERN-OHL1.2+)',
      abbr: 'CERN-OHL', },
    'http://solderpad.org/licenses/SHL-0.51/' => {
      name: 'Solderpad Hardware License version 0.51 or later (SHL0.51+)',
      abbr: 'SHL', },
    'http://solderpad.org/licenses/' => {
      name: 'Solderpad Hardware License (SHL)',
      abbr: 'SHL',
      deprecated: true },
    'http://creativecommons.org/licenses/by/4.0' => {
      name: 'Creative Commons Attribution CC BY version 4.0 or later (CC BY 4+)',
      abbr: 'CC BY', },
    'http://creativecommons.org/licenses/by-sa/4.0' => {
      name: 'Creative Commons Attribution-ShareAlike CC BY-SA version 4.0 or later (CC BY-SA 4+)',
      abbr: 'CC BY-SA', },
    'http://creativecommons.org/licenses/by-nd/4.0' => {
      name: 'Creative Commons Attribution-NoDerivs CC BY-ND version 4.0 or later (CC BY-ND 4+)',
      abbr: 'CC BY-ND', },
    'http://creativecommons.org/licenses/by-nc/4.0' => {
      name: 'Creative Commons Attribution-NonCommercial CC BY-NC version 4.0 or later (CC BY-NC 4+)',
      abbr: 'CC BY-NC', },
    'http://creativecommons.org/licenses/by-nc-sa/4.0' => {
      name: 'Creative Commons Attribution-NonCommercial-ShareAlike CC BY-NC-SA version 4.0 or later (CC BY-NC-SA 4+)',
      abbr: 'CC BY-NC-SA', },
    'http://creativecommons.org/licenses/by-nc-nd/4.0' => {
      name: 'Creative Commons Attribution-NonCommercial-NoDerivs CC BY-NC-ND version 4.0 or later (CC BY-NC-ND 4+)',
      abbr: 'CC BY-NC-ND', },
    'https://tldrlegal.com/license/beerware-license' => {
      name: 'Beerware',
      abbr: 'Beerware',
      deprecated: true
    }
  }

  attr_reader :url, :name, :abbr

  def self.all
    LICENSE_TYPES.select do |url, attrs|
      !attrs[:deprecated]
    end.map do |url, attrs|
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