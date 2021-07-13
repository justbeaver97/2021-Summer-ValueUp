// 일반 배치 모드

/*
 * Copyright 2018 Google LLC. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.ar.sceneform.samples.gltf;

import static java.util.concurrent.TimeUnit.SECONDS;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.ArraySet;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;
import android.widget.Button;

import com.google.android.filament.gltfio.Animator;
import com.google.android.filament.gltfio.FilamentAsset;
import com.google.ar.core.Anchor;
import com.google.ar.core.HitResult;
import com.google.ar.core.Plane;
import com.google.ar.sceneform.AnchorNode;
import com.google.ar.sceneform.Node;
import com.google.ar.sceneform.math.Vector3;
import com.google.ar.sceneform.rendering.Color;
import com.google.ar.sceneform.rendering.Material;
import com.google.ar.sceneform.rendering.ModelRenderable;
import com.google.ar.sceneform.rendering.Renderable;
import com.google.ar.sceneform.rendering.ViewRenderable;
import com.google.ar.sceneform.ux.ArFragment;
import com.google.ar.sceneform.ux.TransformableNode;
import com.google.ar.sceneform.ux.TranslationController;

import java.lang.ref.WeakReference;
import java.util.Arrays;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

/**
 * This is an example activity that uses the Sceneform UX package to make common AR tasks easier.
 */
public class GltfActivity extends AppCompatActivity {
    private static final String TAG = GltfActivity.class.getSimpleName(); // log 띄우기 위해
    private static final double MIN_OPENGL_VERSION = 3.0;

    private ArFragment arFragment; // ARCORE 기본 구성 사용
    private Renderable renderable; // 3D object rendering 위함


    private static class AnimationInstance { // animation을 만들기 위해 사용되는 데이터들
        Animator animator;
        Long startTime;
        float duration;
        int index;

        AnimationInstance(Animator animator, int index, Long startTime) {
            this.animator = animator;
            this.startTime = startTime;
            this.duration = animator.getAnimationDuration(index);
            this.index = index;
        }

        public AnimationInstance(com.google.android.filament.gltfio.Animator animator, int index, long startTime) {
        }
    }

    private final Set<AnimationInstance> animators = new ArraySet<>(); // animationInstance 저장하기 위해 ArraySet 생성

    private final List<Color> colors =
            Arrays.asList(
                    new Color(0, 0, 0, 1),
                    new Color(1, 0, 0, 1),
                    new Color(0, 1, 0, 1),
                    new Color(0, 0, 1, 1),
                    new Color(1, 1, 0, 1),
                    new Color(0, 1, 1, 1),
                    new Color(1, 0, 1, 1),
                    new Color(1, 1, 1, 1));
    private int nextColor = 0; //

    @Override
    @SuppressWarnings({"AndroidApiChecker", "FutureReturnValueIgnored"})
    // CompletableFuture requires api level 24
    // FutureReturnValueIgnored is not valid
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!checkIsSupportedDeviceOrFinish(this)) {
            return;
        } // 지원하는 OpenGL 버전(3.0)이 적합한지, android sdk 버전이 맞는지 확인

        setContentView(R.layout.activity_ux);

        // -----
        Intent intent = getIntent();
        String key = (String) intent.getSerializableExtra("key");
        int length = (int) intent.getSerializableExtra("size"); // get items -> key, size(length)

        Button button_distance = (Button)findViewById(R.id.button_distance);
        button_distance.setOnClickListener(new View.OnClickListener(){ // button Click -> setOnClickListener
            @Override
            public void onClick(View v){
                Toast.makeText(getApplicationContext(),"거리 측정페이지입니다.",Toast.LENGTH_LONG).show();
                Intent pageIntent = new Intent(GltfActivity.this, DistanceActivity.class); // 거리측정페이지 : DistanceActivity
                pageIntent.putExtra("length", length); // length 전달
                startActivity(pageIntent);
            }

        });
        // -----

//
//        String newUri = "http://image.hanssem.com/hsimg/gds3d/dk/" + key + ".glb";

        arFragment = (ArFragment) getSupportFragmentManager().findFragmentById(R.id.ux_fragment); // ux_fragment -> fragment manager 불러옴 -> ARFragment

        WeakReference<GltfActivity> weakActivity = new WeakReference<>(this); // Weakreference -> MemoryLeak X

        ModelRenderable.builder() // Sceneform rendering engine
                .setSource(
                        this,
                        Uri.parse(
//                                newUri))
                                "https://raw.githubusercontent.com/justbeaver97/2021-1-CapstoneDesign/master/threejs_tutorial/models/746525_close.glb")) // our .glb model
                .setIsFilamentGltf(true) // gltf load
                .build()
                .thenAccept(
                        modelRenderable -> {
                            GltfActivity activity = weakActivity.get();
                            if (activity != null) {
                                activity.renderable = modelRenderable; // modelRenderable(our .glb file) -> renderable
                            }
                        })
                .exceptionally( // exception
                        throwable -> {
                            Toast toast =
                                    Toast.makeText(this, "인테리어 파일을 불러올 수 없습니다.", Toast.LENGTH_LONG);
                            toast.setGravity(Gravity.CENTER, 0, 0);
                            toast.show();
                            return null;
                        });

        arFragment.setOnTapArPlaneListener( // Plane의 white dot tap하면 function 실행 -> hitresult(x,y), plane, motionEvent -> Anchor 생성 가능
                (HitResult hitResult, Plane plane, MotionEvent motionEvent) -> {
                    if (renderable == null) {
                        return;
                    }

                    // Create the Anchor.
                    Anchor anchor = hitResult.createAnchor(); // create anchor
                    AnchorNode anchorNode = new AnchorNode(anchor); // Object가 배치되는 영역인 Node를 Anchor 할당 생성 -> AnchorNode
                    anchorNode.setParent(arFragment.getArSceneView().getScene()); // (getScene : 장면 반환 / getArSceneView : 장면 랜더링(arsceneview) 반환) -> parentNode로 set

                    // Create the transformable model and add it to the anchor.
                    TransformableNode model = new TransformableNode(arFragment.getTransformationSystem()); // TransformableNode -> 선택, 변환, 회전, 크기 조정 가능한 Node
                    model.setRenderable(renderable); // set rendering model
                    model.getScaleController().setMaxScale(0.015f);
                    model.getScaleController().setMinScale(0.005f); // set Scale
                    model.setParent(anchorNode); // Anchor node 위에 model set -> 부모 설정
                    model.select();

                    // Filament -> android, iOS 등 WebGL을 위한 실시간 Rendering engine
                    FilamentAsset filamentAsset = model.getRenderableInstance().getFilamentAsset(); // filamentAsset = filament에서 사용할 3D 모델(.glb file) 정의
                    if (filamentAsset.getAnimator().getAnimationCount() > 0) {
                        animators.add(new AnimationInstance(filamentAsset.getAnimator(), 0, System.nanoTime())); // Array set animators -> add Instance
                    }

                    Color color = colors.get(nextColor); // basic color setting
                    nextColor++;
                    for (int i = 0; i < renderable.getSubmeshCount(); ++i) {
                        Material material = renderable.getMaterial(i);
                        material.setFloat4("baseColorFactor", color);
                    }

                });

        arFragment
                .getArSceneView()
                .getScene()
                .addOnUpdateListener( // Scene이 update되기 직전 frame 당 한번 호출될 콜백함수
                        frameTime -> {
                            Long time = System.nanoTime(); // nanotime 만큼씩
                            for (AnimationInstance animator : animators) {
                                animator.animator.applyAnimation(
                                        animator.index,
                                        (float) ((time - animator.startTime) / (double) SECONDS.toNanos(1))
                                                % animator.duration);
                                animator.animator.updateBoneMatrices();
                            } // set animation
                        });
    }


    public static boolean checkIsSupportedDeviceOrFinish(final Activity activity) { // version check function
        if (Build.VERSION.SDK_INT < VERSION_CODES.N) {
            Log.e(TAG, "Sceneform requires Android N or later");
            Toast.makeText(activity, "Sceneform requires Android N or later", Toast.LENGTH_LONG).show();
            activity.finish();
            return false;
        }
        String openGlVersionString =
                ((ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE))
                        .getDeviceConfigurationInfo()
                        .getGlEsVersion();
        if (Double.parseDouble(openGlVersionString) < MIN_OPENGL_VERSION) {
            Log.e(TAG, "Sceneform requires OpenGL ES 3.0 later");
            Toast.makeText(activity, "Sceneform requires OpenGL ES 3.0 or later", Toast.LENGTH_LONG)
                    .show();
            activity.finish();
            return false;
        }
        return true;
    }
}
