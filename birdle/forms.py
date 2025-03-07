from django import forms
from django.db.models import Q
from .models import Bird, BirdRegion, Region


class BirdRegionForm(forms.Form):
    region = forms.ChoiceField(widget=forms.Select(attrs={"class": "form-control"}))
    family = forms.ChoiceField(widget=forms.Select(attrs={"class": "form-control"}))
    allow_list = forms.CharField(widget=forms.Textarea(attrs={"class": "form-control"}), required=False)

    def __init__(self, *args, **kwargs):
        super(BirdRegionForm, self).__init__(*args, **kwargs)
        self.fields['region'].choices = [
            ('Any', 'Any Region'),
            *[(val[0], val[0]) for val in Region.objects.values_list("name").order_by("name")]
        ]

        self.fields['family'].choices = [
            ('Any', 'Any Family'),
            *[(val[0], val[0]) for val in Bird.objects.values_list("family").distinct().order_by("family")]
        ]


    def clean(self):
        cleaned_data = super().clean()
        region = cleaned_data.get('region')
        family = cleaned_data.get('family')
        allow_list = cleaned_data.get('allow_list')

        birdregions = BirdRegion.objects.all()
        if region != "Any":
            birdregions = birdregions.filter(region__name=region)
        if family != "Any":
            birdregions = birdregions.filter(bird__family=family)

        if not birdregions.exists():
            raise forms.ValidationError(f"{family} have not been found in the {region} region.")
        
        if allow_list != "Any":
            bird_list = allow_list.split(',')
            if len(bird_list) > 0:
                qs = Q(bird__name=bird_list[0])
                for bird_name in bird_list[1:]:
                    qs = qs | Q(bird__name=bird_name.lstrip())
                birdregions = birdregions.filter(qs)

        if not birdregions.exists():
            raise forms.ValidationError(f"None of the specified birds in {family} have been found in the {region} region.")

        return cleaned_data
