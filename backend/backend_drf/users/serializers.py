from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
            'id',
            'name',
            'email',
            'gender',
            'date_of_birth',
            'region',
            'password',
            'confirm_password'
        ]

    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({
                "password": "Passwords do not match"
            })
        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')

        user = User.objects.create_user(
            username=validated_data['email'],
            email=validated_data['email'],
            name=validated_data['name'],
            gender=validated_data['gender'],
            date_of_birth=validated_data.get('date_of_birth'),
            region=validated_data.get('region', ''),
            password=validated_data['password']
        )
        return user
    
class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'email',
            'name',
            'gender',
            'date_of_birth',
            'region',
            'profile_image',
            'instagram_username',
            'instagram_connected',
            'tiktok_username',
            'tiktok_connected',
        ]
        read_only_fields = [
            'instagram_username',
            'instagram_connected',
            'tiktok_username',
            'tiktok_connected',
        ]

    def update(self, instance, validated_data):
        email = validated_data.get('email')
        if email:
            instance.username = email
        return super().update(instance, validated_data)