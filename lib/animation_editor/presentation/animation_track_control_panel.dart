
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationTrackControlPanel extends StatelessWidget {
  const AnimationTrackControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(
      builder: (context, entity, _) {
        final animComp = entity.getComponent<AnimationControllerComponent>();
        if (animComp == null) {
          return const Text("No Animation Component");
        }

        return ChangeNotifierProvider.value(
          value: animComp,
          child: Consumer<AnimationControllerComponent>(
            builder: (context, animComp, child) {
              final currentTrack = animComp.currentAnimationTrack;
              final trackNames = animComp.animationTracks.keys.toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown to switch tracks
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<String>(
                      value: currentTrack.name,
                      items: trackNames.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (selected) {
                        if (selected == null || selected == currentTrack.name) return;
                        final newTrack = animComp.animationTracks[selected]!;
                        
                        // Clamp frame index
                        if (animComp.currentFrame >= newTrack.frames.length) {
                          animComp.setFrame(newTrack.frames.length - 1);
                        }
                        animComp.setTrack(selected);
                      },
                    ),
                  ),
                  
                  // Track name + delete
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Track: ${currentTrack.name}",
                            style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          onPressed: () {
                            if (animComp.animationTracks.length <= 1) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("At least one animation track must exist."),
                              ));
                              return;
                            }
                            
                            final currentName = currentTrack.name;
                            animComp.animationTracks.remove(currentName);
                            
                            // Fallback
                            final fallback = animComp.animationTracks.keys.first;
                            animComp.setTrack(fallback);
                            animComp.setFrame(0);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Position Controls
                  ChangeNotifierProvider.value(
                    value: currentTrack,
                    child: Consumer<AnimationTrack>(
                      builder: (context, currentTrack, child) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Position", style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              
                              // X Position Slider
                              Row(
                                children: [
                                  const Text("X: "),
                                  Expanded(
                                    child: Slider(
                                      value: currentTrack.position.dx,
                                      min: -300.0,
                                      max: 300.0,
                                      divisions: 600,
                                      label: currentTrack.position.dx.round().toString(),
                                      onChanged: (value) {
                                        currentTrack.setPosition(Offset(value, currentTrack.position.dy));
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      currentTrack.position.dx.round().toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Y Position Slider
                              Row(
                                children: [
                                  const Text("Y: "),
                                  Expanded(
                                    child: Slider(
                                      value: currentTrack.position.dy,
                                      min: -300.0,
                                      max: 300.0,
                                      divisions: 600,
                                      label: currentTrack.position.dy.round().toString(),
                                      onChanged: (value) {
                                        currentTrack.setPosition(Offset(currentTrack.position.dx, value));
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      currentTrack.position.dy.round().toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Reset Position Button
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    currentTrack.setPosition(Offset.zero);
                                  },
                                  child: const Text("Reset Position"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Checkboxes for looping, mustFinish, and destroy animation
                  ChangeNotifierProvider.value(
                    value: currentTrack,
                    child: Consumer<AnimationTrack>(
                      builder: (context, currentTrack, child) => CheckboxListTile(
                        title: const Text("Looping"),
                        value: currentTrack.isLooping,
                        onChanged: (value) {
                          currentTrack.setIsLooping(value ?? false);
                        },
                      ),
                    ),
                  ),
                  
                  ChangeNotifierProvider.value(
                    value: currentTrack,
                    child: Consumer<AnimationTrack>(
                      builder: (context, currentTrack, child) => CheckboxListTile(
                        title: const Text("Must Finish Before Transition"),
                        value: currentTrack.mustFinish,
                        onChanged: (value) {
                          currentTrack.setMustFinish(value ?? false);
                        },
                      ),
                    ),
                  ),
                  
                  // Destroy Animation Checkbox
                  ChangeNotifierProvider.value(
                    value: currentTrack,
                    child: Consumer<AnimationTrack>(
                      builder: (context, currentTrack, child) => CheckboxListTile(
                        title: const Text("Destroy Animation"),
                        subtitle: const Text("Automatically creates transitions from all other animations"),
                        value: currentTrack.isDestroyAnimationTrack,
                        onChanged: (value) {
                          if (value == true) {
                            animComp.markAsDestroyAnimation(currentTrack.name);
                          } else {
                            animComp.unmarkAsDestroyAnimation(currentTrack.name);
                          }
                        },
                      ),
                    ),
                  ),
                  
                  // Trigger Destroy Button (for testing)
                  if (animComp.hasDestroyAnimation())
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          animComp.triggerDestroy(entity);
                        },
                        child: const Text("Trigger Destroy (Test)"),
                      ),
                    ),
                  
                  const Divider(),
                  
                  // Add new track
                  Center(
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: "Add Animation Track",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildAddTrackDialog(context, animComp),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddTrackDialog(
    BuildContext context,
    AnimationControllerComponent animComp,
  ) {
    final nameController = TextEditingController();
    final frameCountController = TextEditingController(text: "1");
    bool isLooping = true;
    bool mustFinish = false;
    bool isDestroyAnimation = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text("New Animation Track"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Track Name"),
              ),
              TextField(
                controller: frameCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Initial Frame Count"),
              ),
              CheckboxListTile(
                title: const Text("Looping"),
                value: isLooping,
                onChanged: (val) => setState(() => isLooping = val ?? true),
              ),
              CheckboxListTile(
                title: const Text("Must Finish Before Transition"),
                value: mustFinish,
                onChanged: (val) => setState(() => mustFinish = val ?? false),
              ),
              CheckboxListTile(
                title: const Text("Destroy Animation"),
                subtitle: const Text("Creates transitions from all other animations"),
                value: isDestroyAnimation,
                onChanged: (val) => setState(() => isDestroyAnimation = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final count = int.tryParse(frameCountController.text.trim()) ?? 1;

                if (name.isEmpty || animComp.animationTracks.containsKey(name)) {
                  Navigator.pop(context);
                  return;
                }

                final newTrack = AnimationTrack(
                  name, 
                  [], 
                  isLooping, 
                  mustFinish,
                  isDestroyAnimationTrack: isDestroyAnimation,
                );
                
                for (int i = 0; i < count; i++) {
                  newTrack.addFrame(KeyFrame(sketches: []));
                }

                animComp.animationTracks[name] = newTrack;
                animComp.setTrack(name);
                animComp.setFrame(0);

                // If marked as destroy animation, generate transitions
                if (isDestroyAnimation) {
                  animComp.markAsDestroyAnimation(name);
                }

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}