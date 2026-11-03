// Copies the Mac game's code-drawn art and synthesised sound into plain files for the Android build.
import AppKit
import SpriteKit
import AVFoundation

let out = CommandLine.arguments[1]
func png(_ t: SKTexture, _ name: String) {
    let rep = NSBitmapImageRep(cgImage: t.cgImage())
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out + "/art/" + name + ".png"))
}
png(Art.softDot, "soft_dot"); png(Art.dot, "dot"); png(Art.ring, "ring"); png(Art.beam, "beam")
png(Art.flameFace, "flame_face"); png(Art.eyes, "eyes"); png(Art.ember, "ember"); png(Art.star, "star")
png(Art.moth, "moth"); png(Art.orb, "orb"); png(Art.ground, "ground")
for f in FlameDef.all { png(Art.flame(f), "flame_" + f.id) }
for k in EnemyKind.allCases { png(Art.enemy(k), "enemy_\(k)") }

func wav(_ b: AVAudioPCMBuffer, _ path: String) {
    let n = Int(b.frameLength); let src = b.floatChannelData![0]
    var d = Data(); func u32(_ v: UInt32) { withUnsafeBytes(of: v.littleEndian) { d.append(contentsOf: $0) } }
    func u16(_ v: UInt16) { withUnsafeBytes(of: v.littleEndian) { d.append(contentsOf: $0) } }
    d.append(contentsOf: Array("RIFF".utf8)); u32(UInt32(36 + n * 2)); d.append(contentsOf: Array("WAVEfmt ".utf8))
    u32(16); u16(1); u16(1); u32(44100); u32(88200); u16(2); u16(16)
    d.append(contentsOf: Array("data".utf8)); u32(UInt32(n * 2))
    for i in 0..<n { u16(UInt16(bitPattern: Int16(max(-1, min(1, src[i])) * 32767))) }
    try! d.write(to: URL(fileURLWithPath: path))
}
let s = Sound.shared
s.buildEffects()
for (name, list) in s.buffers { for (i, b) in list.enumerated() { wav(b, out + "/sfx/\(name)_\(i).wav") } }
wav(s.buildMusic(), out + "/music.wav")
print("dumped")
