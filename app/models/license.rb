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
      name: 'The TAPR Open Hardware License (TAPR-OHL)',
      abbr: 'TAPR-OHL', },
    'http://www.balloonboard.org/docs/Balloon_License_0v2.pdf' => {
      name: 'The Balloon Open Hardware License (BOHL)',
      abbr: 'BOHL', },
    'http://www.opencollector.org/hardlicense/hdpl.html' => {
      name: 'Hardware Design Public License Version 0.04 (HDPL)',
      abbr: 'HDPL', },
    'http://www.ohwr.org/projects/cernohl/wiki' => {
      name: 'CERN Open Hardware Licence (CERN-OHL)',
      abbr: 'CERN-OHL', },
    'http://solderpad.org/licenses/' => {
      name: 'The Solderpad Hardware License (SHL)',
      abbr: 'SHL', },
  }

  attr_reader :url, :name, :abbr

  def initialize url
    @url = url
    @name = LICENSE_TYPES[url][:name]
    @abbr = LICENSE_TYPES[url][:abbr]
  end
end